//
//  LocalizationManager.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 02/08/2026.
//
//  Single source of truth for the app's current display language - mirrors
//  `ThemeManager`'s pattern exactly. `ContentView` reads `locale` and injects
//  it as `.environment(\.locale, _)` on the root view, which is what makes
//  every `Text("literal")`/`Button("literal")` in the app re-resolve against
//  `Localizable.xcstrings` live, with no app restart - the in-app language
//  picker is deliberately independent of the device's own system language.
//

import Foundation

// Not @MainActor, consistent with `ThemeManager` - read from plain,
// non-isolated contexts throughout the app; all mutations happen from
// Settings UI code already on the main thread.
@Observable
final class LocalizationManager {

    static let shared = LocalizationManager()

    private static let storageKey = "selectedLanguage"

    var currentLanguage: LanguageChoice {
        didSet { UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey) }
    }

    var locale: Locale { Locale(identifier: currentLanguage.localeIdentifier) }

    private init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: Self.storageKey)
            .flatMap(LanguageChoice.init(rawValue:)) ?? .english
    }
}

/// Localizes a string that isn't a compile-time `Text("literal")` - most
/// commonly a `switch`-derived value on an enum (`Tone.replyTitle`,
/// `GenderChoice.rawValue`, etc). `Text(someString)` does NOT localize a
/// plain `String` automatically (only the `Text(LocalizedStringKey)`
/// initializer used for literals does), so any dynamic string that needs
/// translation must be wrapped in `Loc.t(...)` at its source.
enum Loc {
    static func t(_ key: String) -> String {
        // The classic `Bundle(path:)` lookup for a specific `.lproj`,
        // rather than `String(localized:locale:)` - this is the
        // long-established, battle-tested pattern for overriding the
        // display language independently of the device's own system
        // locale, and sidesteps any edge cases the newer API might have
        // when asked to resolve a non-default explicit `Locale`.
        guard
            let path = Bundle.main.path(forResource: LocalizationManager.shared.currentLanguage.localeIdentifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
