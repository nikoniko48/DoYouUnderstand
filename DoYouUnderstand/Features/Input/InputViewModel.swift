//
//  InputViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

import SwiftUI

@Observable
final class InputViewModel: StateViewModelProtocol {
    
    var state: ViewState<StateModel> = .loading
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    
    // maybe update later
    private var useMocks: Bool
    
    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
        self.useMocks = useMocks
        self.output = output
        setActions()
        self.state = .loaded(StateModel())
    }
}

// MARK: - Output -

extension InputViewModel {
    
    enum Output {
        case goBack
        case explain
        case reply
    }
}

// MARK: - Actions -

extension InputViewModel {
    
    struct Actions {
        var onAnalyse: (() -> Void)?
        var onTap: ((Tap) -> Void)?
        var onUpdateText: ((String) -> Void)?
        
        enum Tap {
            case back
            case explain
            case reply
            case choosePhoto
            case takePhoto
        }
    }
    
    private func setActions() {
        
        actions.onAnalyse = { [weak self] in
            self?.analyse()
        }
        
        actions.onUpdateText = { [weak self] newText in
            self?.updateText(newText)
        }
        
        actions.onTap = { [weak self] tap in
            guard let self else { return }
            
            switch tap {
            case .back:
                goBack()
            case .reply:
                switchAnalysisType(type: .reply)
            case .explain:
                switchAnalysisType(type: .explain)
            case .choosePhoto:
                choosePhoto()
            case .takePhoto:
                takePhoto()
            }
        }
    }
}

// MARK: - Functions -

extension InputViewModel {
    
    private func analyse() {
        
    }
    
    private func goBack() {
        
    }
    
    private func switchAnalysisType(type: AnalysisType) {
        
    }
    
    private func choosePhoto() {
        
    }
    
    private func takePhoto() {
        
    }
    
    private func updateText(_ newText: String) {
        stateModel.inputText = newText
    }
}
