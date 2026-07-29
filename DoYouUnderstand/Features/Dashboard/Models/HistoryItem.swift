//
//  HistoryItem.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct HistoryItem: Identifiable {
    let id: String
    let snippet: String
    let tone: Tone
    let timestamp: String
    let type: AnalysisType
    
    var typeColor: Color {
        switch type {
        case .explain:
            return Theme.Colors.Text.highlight
        case .reply:
            return Theme.Colors.Main.secondaryAccent
        }
    }
}

extension HistoryItem {

    init(record: HistoryRecord) {
        self.init(
            id: record.id,
            snippet: record.snippet,
            tone: record.tone,
            timestamp: Self.formattedTimestamp(record.timestamp),
            type: record.type
        )
    }

    private static func formattedTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
