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
        var onSelectContext: ((StateModel.CommunicationContext) -> Void)?
        var onSelectGoal: ((StateModel.Goal) -> Void)?
        var onNext: (() -> Void)?
        var onSwipeBack: (() -> Void)?
        var onFinish: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectContext = { [weak self] context in
            self?.selectContext(context)
        }

        actions.onSelectGoal = { [weak self] goal in
            self?.selectGoal(goal)
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

    private func selectContext(_ context: StateModel.CommunicationContext) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedContext = context
        }
    }

    private func selectGoal(_ goal: StateModel.Goal) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.selectedGoal = goal
        }
    }

    private func advance() {
        guard stateModel.currentStep < stateModel.totalSteps - 1 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep += 1
        }
    }

    private func retreat() {
        guard stateModel.currentStep > 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stateModel.currentStep -= 1
        }
    }

    private func finish() {
        // TODO: Persist selected onboarding answers (Supabase) once backend is wired up.
        output(.finishOnboarding)
    }
}
