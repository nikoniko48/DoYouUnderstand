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
        var onCopy: ((UUID) -> Void)?
        var onStartEdit: ((UUID) -> Void)?
        var onCancelEdit: ((UUID) -> Void)?
        var onSaveEdit: ((UUID) -> Void)?
    }
    
    private func setActions() {
        actions.onTapBack = { [weak self] in
            self?.goBack()
        }
        
        actions.onCopy = { [weak self] id in
            self?.copyReply(id: id)
        }
        
        actions.onStartEdit = { [weak self] id in
            self?.startEdit(id: id)
        }
        
        actions.onCancelEdit = { [weak self] id in
            self?.cancelEdit(id: id)
        }
        
        actions.onSaveEdit = { [weak self] id in
            self?.saveEdit(id: id)
        }
    }
}

// MARK: - Functions -

extension ReplyViewModel {
    private func loadData() {
        if useMocks {
            let mockData = ReplyViewModel.StateModel.mock
            
            self.stateModel.originalTone = mockData.originalTone
            self.stateModel.options = mockData.options
            self.state = .loaded(self.stateModel)
        } else {
            // TODO: Live AI Generation Implementation
        }
    }
    
    private func goBack() {
        output(.goBack)
    }
    
    private func copyReply(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        
        let textToCopy = stateModel.options[index].text
        UIPasteboard.general.string = textToCopy
        print("Copied: \(textToCopy)")
        
        stateModel.options[index].isCopied = true
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                self.stateModel.options[idx].isCopied = false
            }
        }
    }
    
    private func startEdit(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        
        stateModel.options[index].draftText = stateModel.options[index].text
        stateModel.options[index].isEditing = true
    }
    
    private func cancelEdit(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        
        stateModel.options[index].isEditing = false
    }
    
    private func saveEdit(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        
        let draft = stateModel.options[index].draftText
        stateModel.options[index].text = draft
        stateModel.options[index].isEditing = false
    }
}
