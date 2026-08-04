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
        let extractedText: String
        let tone: Tone
        let toneScore: Int
        let toneQuote: String
        let replies: [ReplyEntry]
    }

    enum LengthAdjustment {
        case shorten
        case lengthen

        var instruction: String {
            switch self {
            case .shorten:
                return "Make this exact response shorter and more concise while keeping the exact same tone."
            case .lengthen:
                return "Rewrite this exact response to be noticeably longer - it must have meaningfully more words " +
                    "than the original. Keep the exact same meaning and tone; add length only by elaborating on " +
                    "what's already there, never by introducing new points."
            }
        }
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
        var onAdjustLength: ((UUID, LengthAdjustment) -> Void)?
        var onGenerateTone: ((Tone) -> Void)?
        var onChangeLanguage: ((UUID, ReplyLanguage) -> Void)?
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

        actions.onAdjustLength = { [weak self] id, adjustment in
            self?.adjustLength(id: id, adjustment: adjustment)
        }

        actions.onGenerateTone = { [weak self] tone in
            self?.generateTone(tone)
        }

        actions.onChangeLanguage = { [weak self] id, language in
            self?.changeLanguage(id: id, language: language)
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
        // The user may have submitted an image with no typed text - fall back
        // to the AI's transcription so the UI always has real text to show.
        stateModel.originalMessage = payload.originalMessage.isEmpty ? payload.extractedText : payload.originalMessage
        stateModel.originalTone = .init(tone: payload.tone, score: payload.toneScore, quote: payload.toneQuote)
        stateModel.options = payload.replies.map { entry in
            var option = StateModel.ReplyOption(tone: entry.tone, text: entry.text)
            option.activeLanguage = ReplyLanguage.detected(from: entry.text)
            return option
        }
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

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            stateModel.options[index].isTweaking.toggle()
        }
    }

    private func regenerate(id: UUID) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        let instruction = Self.tweakInstruction(for: stateModel.options[index])
        runTweak(id: id, instruction: instruction)
    }

    private func adjustLength(id: UUID, adjustment: LengthAdjustment) {
        runTweak(id: id, instruction: adjustment.instruction)
    }

    private func runTweak(id: UUID, instruction: String) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        guard !stateModel.options[index].isRegenerating else { return }

        guard !UsageLimiter.isAtDailyLimit else {
            stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            return
        }

        let option = stateModel.options[index]
        stateModel.options[index].isRegenerating = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let newText = try await GeminiService.tweak(replyText: option.text, tone: option.tone, instruction: instruction)
                UsageLimiter.recordUsage()
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].text = newText
                    self.stateModel.options[idx].isRegenerating = false
                }
            } catch GeminiService.ServiceError.rateLimited {
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].isRegenerating = false
                }
                self.stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
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

    /// The Tweak panel's `[ AUTO | EN ]` toggle - flips just this one card's
    /// active language and regenerates its text to match, keeping the same
    /// tone. Session-only: it never touches `ReplyLanguagePreferenceStore`,
    /// so the global Settings default is untouched.
    private func changeLanguage(id: UUID, language: ReplyLanguage) {
        guard let index = stateModel.options.firstIndex(where: { $0.id == id }) else { return }
        guard stateModel.options[index].activeLanguage != language else { return }
        guard !stateModel.options[index].isRegenerating else { return }

        guard !UsageLimiter.isAtDailyLimit else {
            stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            return
        }

        let tone = stateModel.options[index].tone
        let text = stateModel.originalMessage
        stateModel.options[index].activeLanguage = language
        stateModel.options[index].isRegenerating = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let newText = try await GeminiService.replyForTone(text: text, tone: tone, targetLanguage: language)
                UsageLimiter.recordUsage()
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].text = newText
                    self.stateModel.options[idx].isRegenerating = false
                }
            } catch GeminiService.ServiceError.rateLimited {
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].isRegenerating = false
                }
                self.stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            } catch {
                if let idx = self.stateModel.options.firstIndex(where: { $0.id == id }) {
                    self.stateModel.options[idx].isRegenerating = false
                }
                self.stateModel.errorMessage = "Couldn't switch that reply's language. Please try again."
            }
        }
    }

    private func generateTone(_ tone: Tone) {
        guard !stateModel.pendingTones.contains(tone) else { return }
        guard !stateModel.options.contains(where: { $0.tone == tone }) else { return }

        guard !UsageLimiter.isAtDailyLimit else {
            stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            return
        }

        let text = stateModel.originalMessage
        stateModel.pendingTones.append(tone)

        Task { [weak self] in
            guard let self else { return }
            do {
                let replyText = try await GeminiService.replyForTone(
                    text: text,
                    tone: tone,
                    targetLanguage: ReplyLanguagePreferenceStore.shared.defaultReplyLanguage
                )
                UsageLimiter.recordUsage()
                self.stateModel.pendingTones.removeAll { $0 == tone }
                var newOption = StateModel.ReplyOption(tone: tone, text: replyText)
                newOption.activeLanguage = ReplyLanguage.detected(from: replyText)
                self.stateModel.options.insert(newOption, at: 0)
            } catch GeminiService.ServiceError.rateLimited {
                self.stateModel.pendingTones.removeAll { $0 == tone }
                self.stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            } catch {
                self.stateModel.pendingTones.removeAll { $0 == tone }
                self.stateModel.errorMessage = "Couldn't generate that tone. Please try again."
            }
        }
    }
}
