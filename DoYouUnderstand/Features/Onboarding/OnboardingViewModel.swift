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
        var onSelectTriggerMessage: ((StateModel.TriggerMessage) -> Void)?
        var onSelectCopingStyle: ((StateModel.CopingStyle) -> Void)?
        var onSelectPlan: ((StateModel.PricingPlan) -> Void)?
        var onNext: (() -> Void)?
        var onSwipeBack: (() -> Void)?
        var onFinish: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectTriggerMessage = { [weak self] message in
            self?.selectTriggerMessage(message)
        }

        actions.onSelectCopingStyle = { [weak self] style in
            self?.selectCopingStyle(style)
        }

        actions.onSelectPlan = { [weak self] plan in
            self?.selectPlan(plan)
        }

        actions.onNext = { [weak self] in
            self?.advance()
        }

        actions.onSwipeBack = { [weak self] in
            self?.retreat()
        }

        actions.onFinish = { [weak self] in
            self?.finish()
        }
    }
}

// MARK: - Functions -

extension OnboardingViewModel {

    private func selectTriggerMessage(_ message: StateModel.TriggerMessage) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedTriggerMessage = message
        }
    }

    private func selectCopingStyle(_ style: StateModel.CopingStyle) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedCopingStyle = style
        }
    }

    private func selectPlan(_ plan: StateModel.PricingPlan) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedPlan = plan
        }
    }

    private func advance() {
        guard stateModel.currentStep < stateModel.totalSteps - 1 else { return }
        stateModel.direction = .forward
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
        if stateModel.isProcessingStep {
            startProcessing()
        }
    }

    private func retreat() {
        guard stateModel.currentStep > 0, stateModel.canSwipeBack else { return }
        cancelProcessing()
        stateModel.direction = .backward
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep -= 1
        }
    }

    private func finish() {
        // TODO: Persist selected onboarding answers (Supabase) once backend is wired up.
        output(.finishOnboarding)
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
        stateModel.direction = .forward
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
    }

    private func cancelProcessing() {
        processingTask?.cancel()
        processingTask = nil
    }
}
