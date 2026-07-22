//
//  ExplanationStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 22/07/2026.
//

import SwiftUI

extension ExplanationViewModel {
    
    @Observable
    final class StateModel: StateModelProtocol {
        var originalMessage: String = ""
        var originalTone: ToneAnalysis?
        var breakdown: Breakdown?
        
        // MARK: - View State
        // 0: "Still confused?" Text + "YEA!" Button
        // 1: ELI5 Mode active + "GOT IT!" Button
        var interactionStep: Int = 0
        
        init(
            originalMessage: String = "",
            originalTone: ToneAnalysis? = nil,
            breakdown: Breakdown? = nil
        ) {
            self.originalMessage = originalMessage
            self.originalTone = originalTone
            self.breakdown = breakdown
        }
    }
}

extension ExplanationViewModel.StateModel {
    
    struct ToneAnalysis {
        let tone: Tone
        let score: Int
    }
    
    struct Breakdown {
        let said: String
        let meant: String
        let subtext: String
        let eli5: String
    }
}
