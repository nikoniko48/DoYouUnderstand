//
//  PrivacyPolicyViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

@Observable
final class PrivacyPolicyViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void

    init(output: @escaping (Output) -> Void) {
        self.output = output
        self.stateModel = StateModel()
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension PrivacyPolicyViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension PrivacyPolicyViewModel {

    struct Actions {
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}
