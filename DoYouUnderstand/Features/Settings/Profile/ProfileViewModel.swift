//
//  ProfileViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

@Observable
final class ProfileViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let profileStore: UserProfileStore
    private var savedConfirmationTask: Task<Void, Never>?

    init(profileStore: UserProfileStore = .shared, output: @escaping (Output) -> Void) {
        self.profileStore = profileStore
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension ProfileViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension ProfileViewModel {

    struct Actions {
        var onNameChanged: ((String) -> Void)?
        var onAgeIncrement: (() -> Void)?
        var onAgeDecrement: (() -> Void)?
        var onSelectGender: ((OnboardingViewModel.StateModel.GenderChoice) -> Void)?
        var onSave: (() -> Void)?
        var onCancel: (() -> Void)?
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onNameChanged = { [weak self] name in
            self?.stateModel.name = name
        }

        actions.onAgeIncrement = { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                self.stateModel.age = min(StateModel.ageRange.upperBound, self.stateModel.age + 1)
            }
        }

        actions.onAgeDecrement = { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                self.stateModel.age = max(StateModel.ageRange.lowerBound, self.stateModel.age - 1)
            }
        }

        actions.onSelectGender = { [weak self] gender in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                self.stateModel.selectedGender = gender
            }
        }

        actions.onSave = { [weak self] in
            self?.save()
        }

        actions.onCancel = { [weak self] in
            self?.cancel()
        }

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}

// MARK: - Functions -

extension ProfileViewModel {

    private func save() {
        profileStore.name = stateModel.name
        profileStore.age = stateModel.age
        profileStore.gender = stateModel.selectedGender

        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.markSaved()
        }

        savedConfirmationTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            stateModel.showsSavedConfirmation = true
        }
        savedConfirmationTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                self?.stateModel.showsSavedConfirmation = false
            }
        }
    }

    private func cancel() {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.revert()
        }
    }
}
