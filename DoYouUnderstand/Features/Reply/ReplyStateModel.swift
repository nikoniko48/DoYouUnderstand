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
        var originalTone: ToneAnalysis?
        var options: [ReplyOption] = []
        
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
        let text: String
    }
}
