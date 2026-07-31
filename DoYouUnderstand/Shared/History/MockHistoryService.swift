//
//  MockHistoryService.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//
//  In-memory only - used for SwiftUI Previews and testing so the Canvas stays
//  fast and populated without touching disk.

import Foundation

final class MockHistoryService: HistoryServiceProtocol {

    private var records: [HistoryRecord]

    init(records: [HistoryRecord] = MockHistoryService.seedData) {
        self.records = records
    }

    func fetchAll() -> [HistoryRecord] {
        records.sorted { $0.timestamp > $1.timestamp }
    }

    func fetch(id: String) -> HistoryRecord? {
        records.first { $0.id == id }
    }

    @discardableResult
    func save(_ payload: HistoryPayload) -> HistoryRecord {
        let record = HistoryRecord(id: UUID().uuidString, timestamp: Date(), payload: payload)
        records.append(record)
        return record
    }

    func delete(id: String) {
        records.removeAll { $0.id == id }
    }
}

// MARK: - Seed Data -

extension MockHistoryService {

    static let seedData: [HistoryRecord] = [
        HistoryRecord(
            id: "mock_1",
            timestamp: Date().addingTimeInterval(-2 * 60),
            payload: .explanation(
                ExplanationViewModel.Payload(
                    originalMessage: "Per my last email, I clearly outlined the deliverables that were expected by EOD. I'm not sure why this is still unclear...",
                    extractedText: "Per my last email, I clearly outlined the deliverables that were expected by EOD. I'm not sure why this is still unclear...",
                    tone: .passiveAggressive,
                    toneScore: 87,
                    said: "\"Per my last email, I clearly outlined the deliverables expected by EOD.\"",
                    meant: "They're frustrated and implying you didn't read their previous message — or that you're being difficult. The phrase \"clearly outlined\" is doing heavy lifting here. It's a power move disguised as a factual statement.",
                    subtext: "\"You should have known better\" and \"I'm keeping a paper trail of your incompetence\" are both very much in the air.",
                    eli5: "They are annoyed because they think they already told you what to do, and they want to make sure everyone knows it's your fault, not theirs!"
                )
            )
        ),
        HistoryRecord(
            id: "mock_2",
            timestamp: Date().addingTimeInterval(-60 * 60),
            payload: .reply(
                ReplyViewModel.Payload(
                    originalMessage: "Just to clarify, we need that finalized by this evening or we might miss the window.",
                    extractedText: "Just to clarify, we need that finalized by this evening or we might miss the window.",
                    tone: .overEager,
                    toneScore: 82,
                    toneQuote: "\"Just to clarify, we need that finalized by this evening or we might miss the window.\"",
                    replies: [
                        .init(
                            tone: .professional,
                            text: "Understood. I am prioritizing this task and will have the finalized version sent over to you before the evening deadline."
                        ),
                        .init(
                            tone: .assertive,
                            text: "I am fully aware of the timeline. You will have the final deliverables by EOD as agreed."
                        ),
                        .init(
                            tone: .friendly,
                            text: "Got it! I'm wrapping it up right now and will send it your way shortly so we don't miss the window."
                        ),
                        .init(
                            tone: .diplomatic,
                            text: "Thanks for the heads up. I'll make sure it's finalized in time for the window - let me know if anything changes on your end."
                        ),
                        .init(
                            tone: .empathetic,
                            text: "No worries, I know this one's time-sensitive. I'm on it and will have it wrapped up well before the deadline."
                        )
                    ]
                )
            )
        ),
        HistoryRecord(
            id: "mock_3",
            timestamp: Date().addingTimeInterval(-2 * 60 * 60),
            payload: .explanation(
                ExplanationViewModel.Payload(
                    originalMessage: "K.",
                    extractedText: "K.",
                    tone: .condescending,
                    toneScore: 92,
                    said: "\"K.\"",
                    meant: "I acknowledge your message, but I am deliberately putting zero effort into my response to show my displeasure or lack of respect for your time.",
                    subtext: "\"You are not worth a full sentence.\"",
                    eli5: "They are mad and want you to know it by giving you the shortest, coldest answer possible."
                )
            )
        ),
        HistoryRecord(
            id: "mock_4",
            timestamp: Date().addingTimeInterval(-5 * 60 * 60),
            payload: .explanation(
                ExplanationViewModel.Payload(
                    originalMessage: "Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!",
                    extractedText: "Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!",
                    tone: .anxious,
                    toneScore: 88,
                    said: "\"Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!\"",
                    meant: "I am extremely stressed that you haven't replied. I need an answer immediately, but I don't want to seem pushy or rude.",
                    subtext: "\"Please reply right now, my anxiety is through the roof.\"",
                    eli5: "They are super worried you forgot about them and are trying to be polite while begging for an answer."
                )
            )
        ),
        HistoryRecord(
            id: "mock_5",
            timestamp: Date().addingTimeInterval(-26 * 60 * 60),
            payload: .explanation(
                ExplanationViewModel.Payload(
                    originalMessage: "Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.",
                    extractedText: "Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.",
                    tone: .sarcastic,
                    toneScore: 95,
                    said: "\"Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.\"",
                    meant: "This meeting is a complete waste of time and I am highly annoyed that I have to attend.",
                    subtext: "\"This company loves useless meetings and disrespects my time.\"",
                    eli5: "They are saying they are happy, but they actually mean they are very, very grumpy about a boring meeting."
                )
            )
        ),
        HistoryRecord(
            id: "mock_6",
            timestamp: Date().addingTimeInterval(-30 * 60 * 60),
            payload: .reply(
                ReplyViewModel.Payload(
                    originalMessage: "Let me explain this one more time so it's a bit easier for you to grasp.",
                    extractedText: "Let me explain this one more time so it's a bit easier for you to grasp.",
                    tone: .condescending,
                    toneScore: 94,
                    toneQuote: "\"Let me explain this one more time so it's a bit easier for you to grasp.\"",
                    replies: [
                        .init(
                            tone: .professional,
                            text: "Thank you for the clarification. I have reviewed the details and am proceeding accordingly to meet the requirements."
                        ),
                        .init(
                            tone: .assertive,
                            text: "There is no need to re-explain. I fully grasp the requirements from the previous communication and am already executing them."
                        ),
                        .init(
                            tone: .friendly,
                            text: "Thanks for breaking it down! I've got a good handle on it now and will get it sorted."
                        ),
                        .init(
                            tone: .blunt,
                            text: "I understood it the first time. Moving on."
                        ),
                        .init(
                            tone: .diplomatic,
                            text: "I appreciate you double-checking. I've got a solid handle on the requirements and I'm already moving forward with them."
                        )
                    ]
                )
            )
        ),
        HistoryRecord(
            id: "mock_7",
            timestamp: Date().addingTimeInterval(-2 * 24 * 60 * 60),
            payload: .explanation(
                ExplanationViewModel.Payload(
                    originalMessage: "I guess we can just do whatever you want. Don't worry about what I had planned.",
                    extractedText: "I guess we can just do whatever you want. Don't worry about what I had planned.",
                    tone: .passiveAggressive,
                    toneScore: 81,
                    said: "\"I guess we can just do whatever you want. Don't worry about what I had planned.\"",
                    meant: "I am furious that we aren't doing it my way, and I'm going to make you feel extremely guilty about it.",
                    subtext: "\"You are selfish and ruined my plans.\"",
                    eli5: "They are acting like it's fine, but they are secretly pouting because they didn't get their way."
                )
            )
        )
    ]
}
