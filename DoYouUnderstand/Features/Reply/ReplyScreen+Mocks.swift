//
//  ReplyScreen+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 19/07/2026.
//

import SwiftUI

extension ReplyViewModel.StateModel {
    
    static func mock(for id: String?) -> ReplyViewModel.StateModel {
        
        switch id {
        case "mock_2": // Over-Eager Urgent
            return ReplyViewModel.StateModel(
                originalTone: ToneAnalysis(tone: .overEager, score: 82, quote: "\"Just to clarify, we need that finalized by this evening or we might miss the window.\""),
                options: [
                    ReplyOption(
                        tone: .professional,
                        text: "Understood. I am prioritizing this task and will have the finalized version sent over to you before the evening deadline."
                    ),
                    ReplyOption(
                        tone: .assertive,
                        text: "I am fully aware of the timeline. You will have the final deliverables by EOD as agreed."
                    ),
                    ReplyOption(
                        tone: .friendly,
                        text: "Got it! I'm wrapping it up right now and will send it your way shortly so we don't miss the window."
                    )
                ]
            )
            
        case "mock_6": // Condescending Boss
            return ReplyViewModel.StateModel(
                originalTone: ToneAnalysis(tone: .condescending, score: 94, quote: "\"Let me explain this one more time so it's a bit easier for you to grasp.\""),
                options: [
                    ReplyOption(
                        tone: .professional,
                        text: "Thank you for the clarification. I have reviewed the details and am proceeding accordingly to meet the requirements."
                    ),
                    ReplyOption(
                        tone: .assertive,
                        text: "There is no need to re-explain. I fully grasp the requirements from the previous communication and am already executing them."
                    ),
                    ReplyOption(
                        tone: .friendly,
                        text: "Thanks for breaking it down! I've got a good handle on it now and will get it sorted."
                    )
                ]
            )
            
        default: // Fallback (Passive Aggressive Default)
            return ReplyViewModel.StateModel(
                originalTone: ToneAnalysis(tone: .passiveAggressive, score: 87, quote: "\"Per my last email, I clearly outlined the deliverables that were expected by EOD...\""),
                options: [
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
            )
        }
    }
}
