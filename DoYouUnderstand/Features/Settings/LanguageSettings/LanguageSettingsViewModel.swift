//
//  LanguageSettingsViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

@Observable
final class LanguageSettingsViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void

    private static let storageKey = "selectedLanguage"

    init(output: @escaping (Output) -> Void) {
        self.output = output
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
            .flatMap(LanguageChoice.init(rawValue:)) ?? .english
        self.stateModel = StateModel(selectedLanguage: stored)
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension LanguageSettingsViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension LanguageSettingsViewModel {

    struct Actions {
        var onSelectLanguage: ((LanguageChoice) -> Void)?
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectLanguage = { [weak self] language in
            self?.selectLanguage(language)
        }

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}

// MARK: - Functions -

extension LanguageSettingsViewModel {

    private func selectLanguage(_ language: LanguageChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedLanguage = language
        }
        UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
    }
}
