//
//  ThemeManager.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//
//  Single source of truth for the app's current visual theme. `Theme.Colors`
//  reads from this (see AppTheme.swift), so changing `appTheme`/`tonePalette`
//  here re-skins the whole app instantly - including live, mid-onboarding,
//  before the user has finished the funnel.
//

import Foundation

// Not @MainActor - `Theme.Colors.*` reads this from many plain, non-isolated
// static contexts throughout the app, consistent with the rest of the
// codebase's lenient (non-strict-concurrency) style. All mutations happen
// from SwiftUI/onboarding UI code, which is already on the main thread.
@Observable
final class ThemeManager {

    static let shared = ThemeManager()

    private static let appThemeKey = "selectedAppTheme"
    private static let tonePaletteKey = "selectedTonePalette"

    var appTheme: AppThemeChoice {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: Self.appThemeKey)
        }
    }

    var tonePalette: TonePaletteChoice {
        didSet {
            UserDefaults.standard.set(tonePalette.rawValue, forKey: Self.tonePaletteKey)
        }
    }

    private init() {
        let storedTheme = UserDefaults.standard.string(forKey: Self.appThemeKey)
            .flatMap(AppThemeChoice.init(rawValue:))
        let storedPalette = UserDefaults.standard.string(forKey: Self.tonePaletteKey)
            .flatMap(TonePaletteChoice.init(rawValue:))

        // Before anything's ever been picked, match the device's own
        // Light/Dark setting rather than forcing Dark - so onboarding starts
        // looking like the rest of the user's phone, not a surprise.
        self.appTheme = storedTheme ?? .systemPreferred
        self.tonePalette = storedPalette ?? .classic
    }
}
