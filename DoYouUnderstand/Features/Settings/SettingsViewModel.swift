//
//  SettingsViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

@Observable
final class SettingsViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private var useMocks: Bool

    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
        self.useMocks = useMocks
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension SettingsViewModel {

    enum Output {
        case goBack
        case profile
        case theme
        case language
        case manageSubscription
        case privacyPolicy
        case faq
    }
}

// MARK: - Actions -

extension SettingsViewModel {

    struct Actions {
        var onTapBack: (() -> Void)?
        var onTapProfile: (() -> Void)?
        var onTapTheme: (() -> Void)?
        var onTapLanguage: (() -> Void)?
        var onTapManageSubscription: (() -> Void)?
        var onTapPrivacyPolicy: (() -> Void)?
        var onTapFAQ: (() -> Void)?
        var onAppear: (() -> Void)?
    }

    private func setActions() {

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }

        actions.onTapProfile = { [weak self] in
            self?.output(.profile)
        }

        actions.onTapTheme = { [weak self] in
            self?.output(.theme)
        }

        actions.onTapLanguage = { [weak self] in
            self?.output(.language)
        }

        actions.onTapManageSubscription = { [weak self] in
            self?.output(.manageSubscription)
        }

        actions.onTapPrivacyPolicy = { [weak self] in
            self?.output(.privacyPolicy)
        }

        actions.onTapFAQ = { [weak self] in
            self?.output(.faq)
        }

        // Settings stays alive on the nav stack while the user edits their
        // profile in a pushed screen - refresh from the shared store each
        // time this screen becomes visible again so the summary card
        // doesn't show stale data after a pop back.
        actions.onAppear = { [weak self] in
            self?.refreshProfile()
        }
    }
}

// MARK: - Functions -

extension SettingsViewModel {

    private func refreshProfile() {
        stateModel.name = UserProfileStore.shared.name
        stateModel.age = UserProfileStore.shared.age
        stateModel.gender = UserProfileStore.shared.gender
        stateModel.selectedLanguage = StateModel.loadSelectedLanguage()
    }
}
