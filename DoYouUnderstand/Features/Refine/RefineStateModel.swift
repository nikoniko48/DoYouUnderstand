//
//  RefineStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

extension RefineViewModel {

    @Observable
    final class StateModel: StateModelProtocol {

        // MARK: - Transferred Draft Card
        var originalMessage: String = ""
        var isEditingDraft: Bool = false
        var draftEditText: String = ""

        // MARK: - Tone Analysis Card
        // `tone` is empty until the initial `refineAnalyze` call resolves -
        // drives the card's own loading state (see `isAnalyzingTone`).
        // `colorTone` is a separate, fixed-`Tone` classification of the
        // same vibe, used purely to color the card - `tone` itself stays
        // freeform text for display.
        var tone: String = ""
        var colorTone: Tone = .professional
        var summary: String = ""

        // MARK: - Refinement Quick-Actions
        var activeAction: RefineAction?
        var refinedText: String?
        var isRefining: Bool = false

        // MARK: - Refined Result Card
        var isEditingResult: Bool = false
        var resultEditText: String = ""
        var isCopied: Bool = false

        var errorMessage: String?
        var limitReachedMessage: String?
        // Set when Shorten/Lengthen is tapped but the draft is already past
        // that action's own usable range (see `RefineViewModel.runAction`) -
        // shown as an alert instead of ever calling Gemini, since asking the
        // AI to shrink an already-tiny message or grow an already-long one
        // is exactly the kind of prompt that leaves it stuck spinning for a
        // long time before failing anyway.
        var refineActionBlockedMessage: String?

        var isAnalyzingTone: Bool { tone.isEmpty }
    }
}
