//
//  ProfileStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

extension ProfileViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var name: String
        var age: Double
        var selectedGender: OnboardingViewModel.StateModel.GenderChoice?
        var showsSavedConfirmation: Bool = false

        // Snapshot of what's actually persisted - lets edits stay purely
        // local (staged) until Save, and lets Cancel revert cleanly without
        // re-reading from UserProfileStore.
        private var savedName: String
        private var savedAge: Double
        private var savedGender: OnboardingViewModel.StateModel.GenderChoice?

        init(
            name: String = UserProfileStore.shared.name,
            age: Double = UserProfileStore.shared.age,
            selectedGender: OnboardingViewModel.StateModel.GenderChoice? = UserProfileStore.shared.gender
        ) {
            self.name = name
            self.age = age
            self.selectedGender = selectedGender
            self.savedName = name
            self.savedAge = age
            self.savedGender = selectedGender
        }

        static let ageRange = OnboardingViewModel.StateModel.ageRange

        var isNameValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var initials: String {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return "?" }
            return String(trimmed.prefix(1)).uppercased()
        }

        var hasUnsavedChanges: Bool {
            name != savedName || age != savedAge || selectedGender != savedGender
        }

        func markSaved() {
            savedName = name
            savedAge = age
            savedGender = selectedGender
        }

        func revert() {
            name = savedName
            age = savedAge
            selectedGender = savedGender
        }
    }
}
