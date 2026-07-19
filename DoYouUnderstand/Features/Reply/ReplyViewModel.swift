//
//  ReplyViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 19/07/2026.
//

import SwiftUI

@Observable
final class ReplyViewModel: StateViewModelProtocol {
    
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

extension ReplyViewModel {
    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension ReplyViewModel {
    
    struct Actions {
        var onTapBack: (() -> Void)?
        var onCopy: ((String) -> Void)?
        var onEdit: ((ReplyViewModel.StateModel.ReplyOption) -> Void)?
    }
    
    private func setActions() {
        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
        
        actions.onCopy = { text in
            // Use native clipboard
            UIPasteboard.general.string = text
            // TODO: Trigger a toast or success feedback
            print("Copied: \(text)")
        }
        
        actions.onEdit = { option in
            // TODO: Handle routing to an editor or opening a sheet
            print("Editing: \(option.tone)")
        }
    }
}

// MARK: - Functions -

extension ReplyViewModel {
    private func loadData() {
        if useMocks {
            let mockData = StateModel.mock
            
            self.stateModel.originalTone = mockData.originalTone
            self.stateModel.options = mockData.options
            self.state = .loaded(self.stateModel)
        } else {
            // TODO: Live AI Generation Implementation
        }
    }
}
