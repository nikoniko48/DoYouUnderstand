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
    }
}

// MARK: - Actions -

extension SettingsViewModel {

    struct Actions {
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}
