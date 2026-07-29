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

extension ReplyViewModel {
    enum Output {
        case goBack
    }
}

// MARK: - Destination & Payload -

extension ReplyViewModel {

    enum Destination: Hashable {
        case history(id: String)
        case result(Payload)
    }

    struct Payload: Hashable, Codable {
        struct ReplyEntry: Hashable, Codable {
            let tone: Tone
            let text: String
        }

        let originalMessage: String
        let tone: Tone
        let toneScore: Int
        let toneQuote: String
        let replies: [ReplyEntry]
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
        var onToggleTweak: ((UUID) -> Void)?
        var onRegenerate: ((UUID) -> Void)?
        var onGenerateMoreTones: (() -> Void)?
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

        actions.onToggleTweak = { [weak self] id in
            self?.toggleTweak(id: id)
        }

        actions.onRegenerate = { [weak self] id in
            self?.regenerate(id: id)
        }

        actions.onGenerateMoreTones = { [weak self] in
            self?.generateMoreTones()
        }
    }
}

// MARK: - Functions -

extension ReplyViewModel {
    
    private func loadData() {
        switch destination {
        case .result(let payload):
            applyPayload(payload)

        case .history(let id):
            guard
                let record = historyService.fetch(id: id),
                case .reply(let payload) = record.payload
            else {
                state = .error("Couldn't find that analysis.")
                return
            }
            applyPayload(payload)
        }
    }

    private func applyPayload(_ payload: Payload) {
        stateModel.originalMessage = payload.originalMessage
        stateModel.originalTone = .init(tone: payload.tone, score: payload.toneScore, quote: payload.toneQuote)
        stateModel.options = payload.replies.map { StateModel.ReplyOption(tone: $0.tone, text: $0.text) }
        state = .loaded(stateModel)
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

    private func toggleTweak(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.options[index].isTweaking.toggle()
        }
    }

    private func regenerate(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        guard !stateModel.options[index].isRegenerating else { return }

        let option = stateModel.options[index]
        let instruction = Self.tweakInstruction(for: option)

        stateModel.options[index].isRegenerating = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let newText = try await GeminiService.tweak(replyText: option.text, tone: option.tone, instruction: instruction)
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].text = newText
                    self.stateModel.options[idx].isRegenerating = false
                }
            } catch {
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].isRegenerating = false
                }
            }
        }
    }

    private static func tweakInstruction(for option: StateModel.ReplyOption) -> String {
        let leaningHigh = option.tweakValue >= 0.5
        let percent = leaningHigh ? Int(option.tweakValue * 100) : Int((1 - option.tweakValue) * 100)
        let label = leaningHigh ? option.tone.tweakHighLabel : option.tone.tweakLowLabel
        return "Shift this reply \(percent)% towards \(label)."
    }

    private func generateMoreTones() {
        guard !stateModel.isGeneratingMoreTones else { return }

        let text = stateModel.originalMessage
        let existingTones = stateModel.options.map { $0.tone }
        stateModel.isGeneratingMoreTones = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let payload = try await GeminiService.reply(text: text, images: [], excludeTones: existingTones)
                let newOptions = payload.replies.map { StateModel.ReplyOption(tone: $0.tone, text: $0.text) }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.stateModel.options.append(contentsOf: newOptions)
                }
            } catch {
                // TODO: surface a user-facing error state.
            }
            self.stateModel.isGeneratingMoreTones = false
        }
    }
}
