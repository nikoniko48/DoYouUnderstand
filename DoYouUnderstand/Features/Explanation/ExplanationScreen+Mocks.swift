//
//  ExplanationScreen+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 22/07/2026.
//

import SwiftUI

extension ExplanationViewModel.StateModel {
    
    static var mock: ExplanationViewModel.StateModel {
        let mockTone = ToneAnalysis(
            tone: .passiveAggressive,
            score: 87
        )
        
        let mockBreakdown = Breakdown(
            said: "\"Per my last email, I clearly outlined the deliverables expected by EOD.\"",
            meant: "They're frustrated and implying you didn't read their previous message — or that you're being difficult. The phrase \"clearly outlined\" is doing heavy lifting here. It's a power move disguised as a factual statement.",
            subtext: "\"You should have known better\" and \"I'm keeping a paper trail of your incompetence\" are both very much in the air.",
            eli5: "They are annoyed because they think they already told you what to do, and they want to make sure everyone knows it's your fault, not theirs!"
        )
        
        return ExplanationViewModel.StateModel(
            originalMessage: "\"Per my last email, I clearly outlined the deliverables that were expected by EOD. I'm not sure why this is still unclear...\"",
            originalTone: mockTone,
            breakdown: mockBreakdown
        )
    }
}
