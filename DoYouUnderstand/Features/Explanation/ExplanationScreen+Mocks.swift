//
//  ExplanationScreen+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 22/07/2026.
//

import SwiftUI

extension ExplanationViewModel.StateModel {
    
    static func mock(for id: String?) -> ExplanationViewModel.StateModel {
        
        switch id {
        case "mock_3": // Condescending "K."
            return ExplanationViewModel.StateModel(
                originalMessage: "K.",
                originalTone: ToneAnalysis(tone: .condescending, score: 92),
                breakdown: Breakdown(
                    said: "\"K.\"",
                    meant: "I acknowledge your message, but I am deliberately putting zero effort into my response to show my displeasure or lack of respect for your time.",
                    subtext: "\"You are not worth a full sentence.\"",
                    eli5: "They are mad and want you to know it by giving you the shortest, coldest answer possible."
                )
            )
            
        case "mock_4": // Anxious
            return ExplanationViewModel.StateModel(
                originalMessage: "Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!",
                originalTone: ToneAnalysis(tone: .anxious, score: 88),
                breakdown: Breakdown(
                    said: "\"Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!\"",
                    meant: "I am extremely stressed that you haven't replied. I need an answer immediately, but I don't want to seem pushy or rude.",
                    subtext: "\"Please reply right now, my anxiety is through the roof.\"",
                    eli5: "They are super worried you forgot about them and are trying to be polite while begging for an answer."
                )
            )
            
        case "mock_5": // Sarcastic
            return ExplanationViewModel.StateModel(
                originalMessage: "Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.",
                originalTone: ToneAnalysis(tone: .sarcastic, score: 95),
                breakdown: Breakdown(
                    said: "\"Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.\"",
                    meant: "This meeting is a complete waste of time and I am highly annoyed that I have to attend.",
                    subtext: "\"This company loves useless meetings and disrespects my time.\"",
                    eli5: "They are saying they are happy, but they actually mean they are very, very grumpy about a boring meeting."
                )
            )
            
        case "mock_7": // Passive Aggressive Guilt Trip
            return ExplanationViewModel.StateModel(
                originalMessage: "I guess we can just do whatever you want. Don't worry about what I had planned.",
                originalTone: ToneAnalysis(tone: .passiveAggressive, score: 81),
                breakdown: Breakdown(
                    said: "\"I guess we can just do whatever you want. Don't worry about what I had planned.\"",
                    meant: "I am furious that we aren't doing it my way, and I'm going to make you feel extremely guilty about it.",
                    subtext: "\"You are selfish and ruined my plans.\"",
                    eli5: "They are acting like it's fine, but they are secretly pouting because they didn't get their way."
                )
            )
            
        default: // "mock_1" (Passive Aggressive Default)
            return ExplanationViewModel.StateModel(
                originalMessage: "Per my last email, I clearly outlined the deliverables that were expected by EOD. I'm not sure why this is still unclear...",
                originalTone: ToneAnalysis(tone: .passiveAggressive, score: 87),
                breakdown: Breakdown(
                    said: "\"Per my last email, I clearly outlined the deliverables expected by EOD.\"",
                    meant: "They're frustrated and implying you didn't read their previous message — or that you're being difficult. The phrase \"clearly outlined\" is doing heavy lifting here. It's a power move disguised as a factual statement.",
                    subtext: "\"You should have known better\" and \"I'm keeping a paper trail of your incompetence\" are both very much in the air.",
                    eli5: "They are annoyed because they think they already told you what to do, and they want to make sure everyone knows it's your fault, not theirs!"
                )
            )
        }
    }
}
