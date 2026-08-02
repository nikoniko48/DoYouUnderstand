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

    init(output: @escaping (Output) -> Void) {
        self.output = output
        self.stateModel = StateModel(
            selectedLanguage: LocalizationManager.shared.currentLanguage,
            selectedReplyLanguage: ReplyLanguagePreferenceStore.shared.defaultReplyLanguage
        )
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
        var onSelectReplyLanguage: ((ReplyLanguage) -> Void)?
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onSelectLanguage = { [weak self] language in
            self?.selectLanguage(language)
        }

        actions.onSelectReplyLanguage = { [weak self] language in
            self?.selectReplyLanguage(language)
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
        LocalizationManager.shared.currentLanguage = language
    }

    private func selectReplyLanguage(_ language: ReplyLanguage) {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.selectedReplyLanguage = language
        }
        ReplyLanguagePreferenceStore.shared.defaultReplyLanguage = language
    }
}
