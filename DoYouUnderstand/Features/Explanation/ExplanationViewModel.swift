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
    private var useMocks: Bool
    
    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
        self.useMocks = useMocks
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
        if useMocks {
            let mockData = ExplanationViewModel.StateModel.mock
            
            self.stateModel.originalMessage = mockData.originalMessage
            self.stateModel.originalTone = mockData.originalTone
            self.stateModel.breakdown = mockData.breakdown
            
            self.state = .loaded(self.stateModel)
        } else {
            // TODO: Live AI Generation Implementation
        }
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
