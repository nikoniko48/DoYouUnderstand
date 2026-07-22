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
            return Theme.Colors.Main.accent
        }
    }
}
