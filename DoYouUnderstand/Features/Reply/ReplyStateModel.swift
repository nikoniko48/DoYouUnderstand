//
//  ReplyStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 19/07/2026.
//

import SwiftUI

extension ReplyViewModel {
    
    @Observable
    final class StateModel: StateModelProtocol {
        var originalMessage: String = ""
        var originalTone: ToneAnalysis?
        var options: [ReplyOption] = []
        /// Tones currently being generated on-demand (a pill tap) - rendered
        /// as skeleton cards above `options` until each one resolves.
        var pendingTones: [Tone] = []
        var limitReachedMessage: String?
        var errorMessage: String?

        /// Every tone not yet generated and not currently generating - these
        /// are the tones still offered as "generate this tone" pills.
        var availableTones: [Tone] {
            let usedTones = Set(options.map(\.tone)).union(pendingTones)
            return Tone.allCases.filter { !usedTones.contains($0) }
        }

        init(originalTone: ToneAnalysis? = nil, options: [ReplyOption] = []) {
            self.originalTone = originalTone
            self.options = options
        }
    }
}

extension ReplyViewModel.StateModel {

    struct ToneAnalysis {
        let tone: Tone
        let score: Int
        let quote: String
    }

    struct ReplyOption: Identifiable, Equatable {
        let id = UUID()
        let tone: Tone
        var text: String
        /// The language this card is currently in. Defaults to whatever the
        /// global Settings preference is at the moment the card is created;
        /// the Tweak panel's language toggle can override it for this one
        /// card, for this session only - it never writes back to Settings.
        var activeLanguage: ReplyLanguage = ReplyLanguagePreferenceStore.shared.defaultReplyLanguage

        var draftText: String = ""
        var isEditing: Bool = false
        var isCopied: Bool = false

        var isTweaking: Bool = false
        var tweakValue: Double = 0.5
        var isRegenerating: Bool = false
    }
}
