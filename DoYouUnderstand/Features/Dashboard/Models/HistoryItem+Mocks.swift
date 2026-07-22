//
//  HistoryItem+Mocks.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

extension HistoryItem {
    
    static let mockPassiveAggressive = HistoryItem(
        id: "mock_1",
        snippet: "Per my last email, I clearly outlined the deliverables expected by EOD...",
        tone: .passiveAggressive,
        timestamp: "2 min ago",
        type: .explain
    )
    
    static let mockUrgent = HistoryItem(
        id: "mock_2",
        snippet: "Just to clarify, we need that finalized by this evening or we might miss the window.",
        tone: .overEager,
        timestamp: "1 hour ago",
        type: .reply
    )
    
    static let mockCold = HistoryItem(
        id: "mock_3",
        snippet: "K.",
        tone: .condescending,
        timestamp: "2 hours ago",
        type: .explain
    )
    
    static let mockAnxious = HistoryItem(
        id: "mock_4",
        snippet: "Hey, just following up on this again... no pressure at all, just wanted to make sure you saw it? Let me know!",
        tone: .anxious,
        timestamp: "5 hours ago",
        type: .explain
    )
    
    static let mockSarcastic = HistoryItem(
        id: "mock_5",
        snippet: "Oh wow, another mandatory sync that could have been a 2-line email. I am absolutely thrilled.",
        tone: .sarcastic,
        timestamp: "Yesterday",
        type: .explain
    )
    
    static let mockToxicBoss = HistoryItem(
        id: "mock_6",
        snippet: "Let me explain this one more time so it's a bit easier for you to grasp.",
        tone: .condescending,
        timestamp: "Yesterday",
        type: .reply
    )
    
    static let mockGuiltTrip = HistoryItem(
        id: "mock_7",
        snippet: "I guess we can just do whatever you want. Don't worry about what I had planned.",
        tone: .passiveAggressive,
        timestamp: "2 days ago",
        type: .explain
    )

    static let mockList: [HistoryItem] = [
        mockPassiveAggressive,
        mockUrgent,
        mockCold,
        mockAnxious,
        mockSarcastic,
        mockToxicBoss,
        mockGuiltTrip
    ]
}
