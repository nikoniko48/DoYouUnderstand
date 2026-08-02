//
//  SettingsStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

extension SettingsViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var name: String
        var age: Double
        var gender: OnboardingViewModel.StateModel.GenderChoice?
        var selectedLanguage: LanguageChoice

        init(
            name: String = UserProfileStore.shared.name,
            age: Double = UserProfileStore.shared.age,
            gender: OnboardingViewModel.StateModel.GenderChoice? = UserProfileStore.shared.gender,
            selectedLanguage: LanguageChoice? = nil
        ) {
            self.name = name
            self.age = age
            self.gender = gender
            self.selectedLanguage = selectedLanguage ?? Self.loadSelectedLanguage()
        }

        static func loadSelectedLanguage() -> LanguageChoice {
            LocalizationManager.shared.currentLanguage
        }

        var hasProfile: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var initials: String {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return "?" }
            return String(trimmed.prefix(1)).uppercased()
        }

        var profileSubtitle: String {
            guard hasProfile else { return Loc.t("Set up your profile") }
            var parts: [String] = [String(format: Loc.t("Age %d"), Int(age))]
            if let gender {
                parts.append(gender.displayName)
            }
            return parts.joined(separator: " · ")
        }
    }
}
