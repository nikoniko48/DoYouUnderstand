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
        var isGeneratingMoreTones: Bool = false
        var limitReachedMessage: String?
        var errorMessage: String?

        /// All 15 tones are already showing - there's nothing left to generate.
        var hasAllTones: Bool {
            options.count >= Tone.allCases.count
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

    struct ReplyOption: Identifiable {
        let id = UUID()
        let tone: Tone
        var text: String

        var draftText: String = ""
        var isEditing: Bool = false
        var isCopied: Bool = false

        var isTweaking: Bool = false
        var tweakValue: Double = 0.5
        var isRegenerating: Bool = false
    }
}
