//
//  OnboardingViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 28/07/2026.
//

import SwiftUI

@Observable
final class OnboardingViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private var useMocks: Bool
    private var processingTask: Task<Void, Never>?
    private var autoAdvanceTask: Task<Void, Never>?

    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
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
        var onSelectTheme: ((AppThemeChoice) -> Void)?
        var onSelectTonePalette: ((TonePaletteChoice) -> Void)?
        var onSelectTriggerMessage: ((StateModel.TriggerMessage) -> Void)?
        var onSelectPlan: ((StateModel.PricingPlan) -> Void)?
        var onNext: (() -> Void)?
        var onFinish: (() -> Void)?
    }

    private func setActions() {

        actions.onNameChanged = { [weak self] name in
            self?.stateModel.name = name
        }

        actions.onAgeChanged = { [weak self] age in
            self?.stateModel.age = age
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

        actions.onFinish = { [weak self] in
            self?.finish()
        }
    }
}

// MARK: - Functions -

extension OnboardingViewModel {

    private func selectTheme(_ theme: AppThemeChoice) {
        // No auto-advance here - the theme step also offers a tone-palette
        // pick below it now, so the user needs a manual Continue.
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTheme = theme
        }
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedAppTheme")
    }

    private func selectTonePalette(_ palette: TonePaletteChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTonePalette = palette
        }
        UserDefaults.standard.set(palette.rawValue, forKey: "selectedTonePalette")
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
