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
        var onSelectTriggerTone: ((StateModel.TriggerTone) -> Void)?
        var onSelectCopingStyle: ((StateModel.CopingStyle) -> Void)?
        var onNext: (() -> Void)?
        var onBack: (() -> Void)?
        var onFinish: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectTriggerTone = { [weak self] tone in
            self?.selectTriggerTone(tone)
        }

        actions.onSelectCopingStyle = { [weak self] style in
            self?.selectCopingStyle(style)
        }

        actions.onNext = { [weak self] in
            self?.advance()
        }

        actions.onBack = { [weak self] in
            self?.retreat()
        }

        actions.onFinish = { [weak self] in
            self?.finish()
        }
    }
}

// MARK: - Functions -

extension OnboardingViewModel {

    private func selectTriggerTone(_ tone: StateModel.TriggerTone) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedTriggerTone = tone
        }
    }

    private func selectCopingStyle(_ style: StateModel.CopingStyle) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedCopingStyle = style
        }
    }

    private func advance() {
        guard stateModel.currentStep < stateModel.totalSteps - 1 else { return }
        stateModel.direction = .forward
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
    }

    private func retreat() {
        guard stateModel.currentStep > 0 else { return }
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
