//
//  RefineViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

@Observable
final class RefineViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let historyService: HistoryServiceProtocol
    private let destination: Destination
    /// The history entry this session is writing to - set immediately when
    /// opened from history, or captured from the first save once the initial
    /// analysis of a fresh draft resolves. Every later save updates this same
    /// record instead of creating a new one.
    private var savedRecordId: String?

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

extension RefineViewModel {
    enum Output {
        case goBack
    }
}

// MARK: - Destination & Payload -

extension RefineViewModel {

    enum Destination: Hashable {
        /// Fresh handoff from the Input screen - just the resolved draft
        /// text (typed, or OCR-extracted from a photo). No analysis has run
        /// yet; this screen runs it on load.
        case draft(String)
        case history(id: String)
    }

    /// Unlike Explain/Reply (whose full analysis is already computed before
    /// navigating), this is only ever built AFTER `refineAnalyze` resolves.
    /// The initial analysis creates the history entry; every quick action
    /// (or manual edit of the result) afterwards overwrites that same entry
    /// in place with the latest `activeAction`/`refinedText`, so reopening a
    /// Refine entry from history shows both the original draft and whatever
    /// refined version was last generated for it.
    struct Payload: Hashable, Codable {
        let originalMessage: String
        let tone: String
        let colorTone: Tone
        let summary: String
        var activeAction: RefineAction? = nil
        var refinedText: String? = nil
    }
}

// MARK: - Actions -

extension RefineViewModel {

    struct Actions {
        var onTapBack: (() -> Void)?
        var onStartEditDraft: (() -> Void)?
        var onCancelEditDraft: (() -> Void)?
        var onSaveEditDraft: (() -> Void)?
        var onSelectAction: ((RefineAction) -> Void)?
        var onStartEditResult: (() -> Void)?
        var onCancelEditResult: (() -> Void)?
        var onSaveEditResult: (() -> Void)?
        var onCopy: (() -> Void)?
    }

    private func setActions() {
        actions.onTapBack = { [weak self] in
            self?.goBack()
        }

        actions.onStartEditDraft = { [weak self] in
            self?.startEditDraft()
        }

        actions.onCancelEditDraft = { [weak self] in
            self?.cancelEditDraft()
        }

        actions.onSaveEditDraft = { [weak self] in
            self?.saveEditDraft()
        }

        actions.onSelectAction = { [weak self] action in
            self?.runAction(action)
        }

        actions.onStartEditResult = { [weak self] in
            self?.startEditResult()
        }

        actions.onCancelEditResult = { [weak self] in
            self?.cancelEditResult()
        }

        actions.onSaveEditResult = { [weak self] in
            self?.saveEditResult()
        }

        actions.onCopy = { [weak self] in
            self?.copyResult()
        }
    }
}

// MARK: - Functions -

extension RefineViewModel {

    private func loadData() {
        switch destination {
        case .draft(let text):
            stateModel.originalMessage = text
            state = .loaded(stateModel)
            analyzeDraft()

        case .history(let id):
            guard
                let record = historyService.fetch(id: id),
                case .refine(let payload) = record.payload
            else {
                state = .error("Couldn't find that analysis.")
                return
            }
            savedRecordId = id
            applyPayload(payload)
            state = .loaded(stateModel)
        }
    }

    private func applyPayload(_ payload: Payload) {
        stateModel.originalMessage = payload.originalMessage
        stateModel.tone = payload.tone
        stateModel.colorTone = payload.colorTone
        stateModel.summary = payload.summary
        stateModel.activeAction = payload.activeAction
        stateModel.refinedText = payload.refinedText
    }

    /// Saves the current state as a new history entry (first analysis of a
    /// fresh draft) or overwrites the entry already tracked by
    /// `savedRecordId` (a later quick action/edit, or any change to a draft
    /// opened from history) - never creates a second Dashboard row for the
    /// same Refine session.
    private func persistToHistory() {
        let payload = Payload(
            originalMessage: stateModel.originalMessage,
            tone: stateModel.tone,
            colorTone: stateModel.colorTone,
            summary: stateModel.summary,
            activeAction: stateModel.activeAction,
            refinedText: stateModel.refinedText
        )
        if let savedRecordId {
            historyService.update(id: savedRecordId, payload: .refine(payload))
        } else {
            savedRecordId = historyService.save(.refine(payload)).id
        }
    }

    private func goBack() {
        output(.goBack)
    }

    private func analyzeDraft() {
        guard !UsageLimiter.isAtDailyLimit else {
            stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            return
        }

        let text = stateModel.originalMessage

        Task { [weak self] in
            guard let self else { return }
            do {
                let analysis = try await GeminiService.refineAnalyze(text: text)
                UsageLimiter.recordUsage()
                self.stateModel.tone = analysis.tone
                self.stateModel.colorTone = analysis.colorTone
                self.stateModel.summary = analysis.summary
                self.persistToHistory()
            } catch GeminiService.ServiceError.rateLimited {
                self.stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            } catch {
                self.stateModel.errorMessage = "Couldn't analyze that draft. Please try again."
            }
        }
    }

    private func startEditDraft() {
        stateModel.draftEditText = stateModel.originalMessage
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.isEditingDraft = true
        }
    }

    private func cancelEditDraft() {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.isEditingDraft = false
        }
    }

    /// Editing the draft invalidates whatever tone analysis and refined
    /// result were based on the old text, so both are cleared and the draft
    /// is re-analyzed from scratch.
    private func saveEditDraft() {
        stateModel.originalMessage = stateModel.draftEditText
        stateModel.isEditingDraft = false
        stateModel.tone = ""
        stateModel.summary = ""
        stateModel.activeAction = nil
        stateModel.refinedText = nil
        analyzeDraft()
    }

    // Below this, there's realistically nothing left to trim - asking
    // Gemini to shorten something like "Lol" or "K." doesn't fail fast, it
    // leaves the model stuck trying to comply with an impossible request,
    // which is what actually caused the long hangs this guards against.
    private static let minShortenableLength = 10
    // The Edge Function's own prompt already caps how much longer it will
    // try to make a message - past this length there isn't a meaningfully
    // "longer" version worth generating, so it's blocked client-side
    // instead of round-tripping to find that out.
    private static let maxLengthenableLength = 500

    /// Each quick-action pill transforms whatever the current best version of
    /// the message is - the previous refined result if one exists yet, or
    /// the original draft on the very first action - so actions compound
    /// (e.g. Fix Grammar then Lengthen lengthens the already-corrected text,
    /// not the original draft again).
    private func runAction(_ action: RefineAction) {
        guard !stateModel.isRefining else { return }

        guard !UsageLimiter.isAtDailyLimit else {
            stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            return
        }

        let text = stateModel.refinedText ?? stateModel.originalMessage

        switch action {
        case .shorten:
            guard text.count > Self.minShortenableLength else {
                stateModel.refineActionBlockedMessage = "This message is already about as short as it gets - there's nothing left to trim."
                return
            }
        case .lengthen:
            guard text.count <= Self.maxLengthenableLength else {
                stateModel.refineActionBlockedMessage = "This message is already pretty long - it can't be lengthened any further."
                return
            }
        case .fixGrammar, .checkClarity:
            break
        }

        stateModel.activeAction = action
        stateModel.isRefining = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await GeminiService.refineTransform(text: text, action: action)
                UsageLimiter.recordUsage()
                self.stateModel.refinedText = result
                self.stateModel.isRefining = false
                self.persistToHistory()
            } catch GeminiService.ServiceError.rateLimited {
                self.stateModel.isRefining = false
                self.stateModel.limitReachedMessage = UsageLimiter.limitReachedMessage
            } catch {
                self.stateModel.isRefining = false
                self.stateModel.errorMessage = "Couldn't refine that message. Please try again."
            }
        }
    }

    private func startEditResult() {
        guard let text = stateModel.refinedText else { return }
        stateModel.resultEditText = text
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.isEditingResult = true
        }
    }

    private func cancelEditResult() {
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.isEditingResult = false
        }
    }

    private func saveEditResult() {
        stateModel.refinedText = stateModel.resultEditText
        stateModel.isEditingResult = false
        persistToHistory()
    }

    private func copyResult() {
        guard let text = stateModel.refinedText else { return }
        UIPasteboard.general.string = text
        stateModel.isCopied = true

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            self.stateModel.isCopied = false
        }
    }
}
