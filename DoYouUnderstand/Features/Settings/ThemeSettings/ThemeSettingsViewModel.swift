//
//  ThemeSettingsViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

@Observable
final class ThemeSettingsViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let themeManager: ThemeManager

    init(themeManager: ThemeManager = .shared, output: @escaping (Output) -> Void) {
        self.themeManager = themeManager
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension ThemeSettingsViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension ThemeSettingsViewModel {

    struct Actions {
        var onSelectTheme: ((AppThemeChoice) -> Void)?
        var onSelectTonePalette: ((TonePaletteChoice) -> Void)?
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectTheme = { [weak self] theme in
            self?.selectTheme(theme)
        }

        actions.onSelectTonePalette = { [weak self] palette in
            self?.selectTonePalette(palette)
        }

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}

// MARK: - Functions -

extension ThemeSettingsViewModel {

    /// Same pairing as onboarding's theme step - Terminal's green-on-black
    /// look clashes with every other tone palette, so picking it here also
    /// suggests the matching Terminal tones. The user can still tap a
    /// different palette row afterward to override it.
    private func selectTheme(_ theme: AppThemeChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTheme = theme
            themeManager.appTheme = theme

            if theme == .terminal {
                stateModel.selectedTonePalette = .terminal
                themeManager.tonePalette = .terminal
            }
        }
    }

    private func selectTonePalette(_ palette: TonePaletteChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedTonePalette = palette
            themeManager.tonePalette = palette
        }
    }
}
