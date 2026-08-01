//
//  ThemeSettingsStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

extension ThemeSettingsViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var selectedTheme: AppThemeChoice
        var selectedTonePalette: TonePaletteChoice

        init(
            selectedTheme: AppThemeChoice = ThemeManager.shared.appTheme,
            selectedTonePalette: TonePaletteChoice = ThemeManager.shared.tonePalette
        ) {
            self.selectedTheme = selectedTheme
            self.selectedTonePalette = selectedTonePalette
        }
    }
}
