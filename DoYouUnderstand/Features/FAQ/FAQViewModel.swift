//
//  FAQViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

@Observable
final class FAQViewModel: StateViewModelProtocol {

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
        loadQuestions()
    }
}

// MARK: - Output -

extension FAQViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension FAQViewModel {

    struct Actions {
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}

// MARK: - Functions -

extension FAQViewModel {

    private func loadQuestions() {
        if useMocks {
            stateModel.questions = FAQItem.mockList
            state = .loaded(stateModel)
        } else {
            // TODO: Fetch FAQ content from Supabase once backend is wired up.
        }
    }
}
