//
//  ExplanationViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 22/07/2026.
//

import SwiftUI

@Observable
final class ExplanationViewModel: StateViewModelProtocol {
    
    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let historyService: HistoryServiceProtocol
    private let destination: Destination

    init(
        historyService: HistoryServiceProtocol = HistoryServiceProvider.shared,
        destination: Destination,
        output: @escaping (Output) -> Void
    ) {
        self.historyService = historyService
        self.destination = destination
        self.output = output
        self.stateModel = StateModel()

        setActions()
        loadData()
    }
}

// MARK: - Output -

extension ExplanationViewModel {
    enum Output {
        case goBack
    }
}

// MARK: - Destination & Payload -

extension ExplanationViewModel {

    enum Destination: Hashable {
        case history(id: String)
        case result(Payload)
    }

    struct Payload: Hashable, Codable {
        let originalMessage: String
        let tone: Tone
        let toneScore: Int
        let said: String
        let meant: String
        let subtext: String
        let eli5: String
    }
}

// MARK: - Actions -

extension ExplanationViewModel {
    
    struct Actions {
        var onTapBack: (() -> Void)?
        var onTapMainAction: (() -> Void)?
    }
    
    private func setActions() {
        actions.onTapBack = { [weak self] in
            self?.goBack()
        }
        
        actions.onTapMainAction = { [weak self] in
            self?.handleMainAction()
        }
    }
}

// MARK: - Functions -

extension ExplanationViewModel {
    
    private func loadData() {
        switch destination {
        case .result(let payload):
            applyPayload(payload)

        case .history(let id):
            guard
                let record = historyService.fetch(id: id),
                case .explanation(let payload) = record.payload
            else {
                state = .error("Couldn't find that analysis.")
                return
            }
            applyPayload(payload)
        }
    }

    private func applyPayload(_ payload: Payload) {
        stateModel.originalMessage = payload.originalMessage
        stateModel.originalTone = .init(tone: payload.tone, score: payload.toneScore)
        stateModel.breakdown = .init(
            said: payload.said,
            meant: payload.meant,
            subtext: payload.subtext,
            eli5: payload.eli5
        )
        state = .loaded(stateModel)
    }

    private func goBack() {
        output(.goBack)
    }
    
    private func handleMainAction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            if stateModel.interactionStep == 0 {
                // Switch to ELI5 Mode
                stateModel.interactionStep = 1
            } else {
                // Final Step: Go back to dashboard
                goBack()
            }
        }
    }
}
