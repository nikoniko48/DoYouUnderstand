//
//  OnboardingViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 28/07/2026.
//

import SwiftUI
import RevenueCat

@Observable
final class OnboardingViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let subscriptionManager: SubscriptionManager
    private let themeManager: ThemeManager
    private var useMocks: Bool
    private var processingTask: Task<Void, Never>?
    private var autoAdvanceTask: Task<Void, Never>?

    init(
        subscriptionManager: SubscriptionManager = .shared,
        themeManager: ThemeManager = .shared,
        useMocks: Bool = false,
        output: @escaping (Output) -> Void
    ) {
        self.subscriptionManager = subscriptionManager
        self.themeManager = themeManager
        self.useMocks = useMocks
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension OnboardingViewModel {

    enum Output {
        case finishOnboarding
    }
}

// MARK: - Actions -

extension OnboardingViewModel {

    struct Actions {
        var onNameChanged: ((String) -> Void)?
        var onAgeChanged: ((Double) -> Void)?
        var onSelectGender: ((StateModel.GenderChoice) -> Void)?
        var onSelectTheme: ((AppThemeChoice) -> Void)?
        var onSelectTonePalette: ((TonePaletteChoice) -> Void)?
        var onSelectTriggerMessage: ((StateModel.TriggerMessage) -> Void)?
        var onSelectPlan: ((StateModel.PricingPlan) -> Void)?
        var onNext: (() -> Void)?
        /// The paywall's real CTA - purchases the selected plan via RevenueCat
        /// and only completes onboarding once the purchase actually succeeds.
        var onStartTrial: (() -> Void)?
        var onRestorePurchases: (() -> Void)?
        /// Completes onboarding directly with no purchase - used by the
        /// debug-only skip button, not the paywall CTA.
        var onFinish: (() -> Void)?
    }

    private func setActions() {

        actions.onNameChanged = { [weak self] name in
            self?.stateModel.name = name
            UserProfileStore.shared.name = name
        }

        actions.onAgeChanged = { [weak self] age in
            self?.stateModel.age = age
            UserProfileStore.shared.age = age
        }

        actions.onSelectGender = { [weak self] gender in
            self?.selectGender(gender)
        }

        actions.onSelectTheme = { [weak self] theme in
            self?.selectTheme(theme)
        }

        actions.onSelectTonePalette = { [weak self] palette in
            self?.selectTonePalette(palette)
        }

        actions.onSelectTriggerMessage = { [weak self] message in
            self?.selectTriggerMessage(message)
        }

        actions.onSelectPlan = { [weak self] plan in
            self?.selectPlan(plan)
        }

        actions.onNext = { [weak self] in
            self?.advance()
        }

        actions.onStartTrial = { [weak self] in
            self?.startTrial()
        }

        actions.onRestorePurchases = { [weak self] in
            self?.restorePurchases()
        }

        actions.onFinish = { [weak self] in
            self?.finish()
        }
    }
}

// MARK: - Functions -

extension OnboardingViewModel {

    private func selectGender(_ gender: StateModel.GenderChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedGender = gender
            UserProfileStore.shared.gender = gender
        }
    }

    private func selectTheme(_ theme: AppThemeChoice) {
        // No auto-advance here - the theme step also offers a tone-palette
        // pick below it now, so the user needs a manual Continue.
        // Updating ThemeManager (not just local/persisted state) is what
        // makes the whole app re-skin live, right here in onboarding -
        // ThemeManager's own didSet handles persisting it for next launch.
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTheme = theme
            themeManager.appTheme = theme

            // Terminal's green-on-black look clashes with every other tone
            // palette, so picking it suggests the matching Terminal tones
            // too - the user can still tap a different palette afterward.
            if theme == .terminal {
                stateModel.selectedTonePalette = .terminal
                themeManager.tonePalette = .terminal
            }
        }
    }

    private func selectTonePalette(_ palette: TonePaletteChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTonePalette = palette
            themeManager.tonePalette = palette
        }
    }

    private func selectTriggerMessage(_ message: StateModel.TriggerMessage) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedTriggerMessage = message
        }
        autoAdvanceAfterSelection()
    }

    private func selectPlan(_ plan: StateModel.PricingPlan) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedPlan = plan
        }
    }

    private func advance() {
        guard stateModel.currentStep < stateModel.totalSteps - 1 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
        if stateModel.isProcessingStep {
            startProcessing()
        }
        // Safety net in case the launch-time fetch in `SubscriptionManager.start()`
        // hasn't finished (or failed) by the time the user reaches the paywall.
        if stateModel.isFinisherStep, subscriptionManager.currentOffering == nil {
            Task { [weak self] in
                await self?.subscriptionManager.fetchOfferings()
            }
        }
    }

    private func finish() {
        // TODO: Persist selected onboarding answers (Supabase) once backend is wired up.
        output(.finishOnboarding)
    }

    /// The trigger-message step advances on its own shortly after a tap, so
    /// the user has a moment to actually read the selected bubble before the
    /// slide transition kicks in.
    private func autoAdvanceAfterSelection() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            self?.advance()
        }
    }
}

// MARK: - Fake Processing -

extension OnboardingViewModel {

    private func startProcessing() {
        stateModel.processingMessageIndex = 0

        processingTask = Task { [weak self] in
            guard let self else { return }
            let tickNanoseconds: UInt64 = 500_000_000

            for _ in 0..<StateModel.processingTickCount {
                try? await Task.sleep(nanoseconds: tickNanoseconds)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.stateModel.processingMessageIndex += 1
                }
            }

            guard !Task.isCancelled else { return }
            self.finishProcessing()
        }
    }

    private func finishProcessing() {
        processingTask = nil
        guard stateModel.isProcessingStep else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
    }
}

// MARK: - Purchasing -

extension OnboardingViewModel {

    private func startTrial() {
        guard !stateModel.isPurchasing else { return }

        guard let offering = subscriptionManager.currentOffering,
              let package = stateModel.selectedPlan.package(in: offering) else {
            stateModel.purchaseErrorMessage = "We couldn't load the subscription plans. Please check your connection and try again."
            return
        }

        stateModel.isPurchasing = true
        Task { [weak self] in
            guard let self else { return }
            let outcome = await self.subscriptionManager.purchase(package)
            self.stateModel.isPurchasing = false

            switch outcome {
            case .success:
                self.finish()
            case .cancelled:
                break
            case .failure(let message):
                self.stateModel.purchaseErrorMessage = message
            }
        }
    }

    private func restorePurchases() {
        guard !stateModel.isPurchasing else { return }

        stateModel.isPurchasing = true
        Task { [weak self] in
            guard let self else { return }
            let restored = await self.subscriptionManager.restorePurchases()
            self.stateModel.isPurchasing = false

            if restored {
                self.finish()
            } else {
                self.stateModel.purchaseErrorMessage = "No active subscription was found to restore."
            }
        }
    }
}

extension OnboardingViewModel.StateModel.PricingPlan {

    /// Not `fileprivate` - `ManageSubscriptionViewModel` (Settings) reuses
    /// this to purchase the same plans post-onboarding.
    func package(in offering: Offering) -> Package? {
        switch self {
        case .monthly: return offering.monthly
        case .annual: return offering.annual
        }
    }
}
