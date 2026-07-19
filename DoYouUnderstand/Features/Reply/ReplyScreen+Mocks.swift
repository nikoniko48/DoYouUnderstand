//
//  ReplyScreen+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 19/07/2026.
//

import SwiftUI

// TODO: name every screen Screen and check extensions if they make sense

extension ReplyViewModel.StateModel {
    
    static var mock: ReplyViewModel.StateModel {
        let mockTone = ToneAnalysis(
            tone: .passiveAggressive,
            score: 87,
            quote: "\"Per my last email, I clearly outlined the deliverables that were expected by EOD...\""
        )
        
        let mockOptions = [
            ReplyOption(
                tone: .professional,
                text: "Thank you for following up. I apologize for any confusion around the deliverables. I've reviewed your previous email and I'm now clear on the expectations. I'll ensure everything is completed within the revised timeline. Please let me know if you need anything else."
            ),
            ReplyOption(
                tone: .assertive,
                text: "I've read through the email and understand what's needed. The confusion was on my end — I'll have everything done by EOD. Going forward, a quick check-in would help both of us avoid these situations."
            ),
            ReplyOption(
                tone: .friendly,
                text: "Hey! Thanks for bumping this. Totally my bad on the mix-up with the deliverables. I'm on it now and will get it over to you by EOD. Appreciate your patience!"
            )
        ]
        
        return ReplyViewModel.StateModel(originalTone: mockTone, options: mockOptions)
    }
}
