//
//  UserProfileStore.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// The user's name/age/gender, first collected during onboarding. Persisted
/// on-device (no backend yet - see `OnboardingViewModel.finish()`'s TODO) so
/// the Settings Profile screen has something real to show and edit.
///
/// Not @MainActor, consistent with `ThemeManager` - read from plain static
/// contexts, mutated only from onboarding/profile UI code already on the
/// main thread.
@Observable
final class UserProfileStore {

    static let shared = UserProfileStore()

    private static let nameKey = "userProfileName"
    private static let ageKey = "userProfileAge"
    private static let genderKey = "userProfileGender"

    var name: String {
        didSet { UserDefaults.standard.set(name, forKey: Self.nameKey) }
    }
    var age: Double {
        didSet { UserDefaults.standard.set(age, forKey: Self.ageKey) }
    }
    var gender: OnboardingViewModel.StateModel.GenderChoice? {
        didSet { UserDefaults.standard.set(gender?.rawValue, forKey: Self.genderKey) }
    }

    private init() {
        self.name = UserDefaults.standard.string(forKey: Self.nameKey) ?? ""
        let storedAge = UserDefaults.standard.double(forKey: Self.ageKey)
        self.age = storedAge == 0 ? 25 : storedAge
        self.gender = UserDefaults.standard.string(forKey: Self.genderKey)
            .flatMap(OnboardingViewModel.StateModel.GenderChoice.init(rawValue:))
    }

    var hasProfile: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
