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
        let extractedText: String
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
        // The user may have submitted an image with no typed text - fall back
        // to the AI's transcription so the UI never shows a blank message.
        stateModel.originalMessage = payload.originalMessage.isEmpty ? payload.extractedText : payload.originalMessage
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
    
    /// Toggles between the breakdown tiles and the plain-English summary -
    /// this never leaves the screen. Only the header's back button does
    /// that (previously "GOT IT!" called goBack(), which meant the button
    /// unexpectedly exited straight to Dashboard instead of just returning
    /// to the tiles).
    private func handleMainAction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            stateModel.interactionStep = stateModel.interactionStep == 0 ? 1 : 0
        }
    }
}
