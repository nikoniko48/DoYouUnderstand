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
    
    var toneColor: Color {
        switch tone {
        case .anxious:
            return Theme.Colors.Tone.anxious
        case .condescending:
            return Theme.Colors.Tone.condescending
        case .overEager:
            return Theme.Colors.Tone.overEager
        case .passiveAggressive:
            return Theme.Colors.Tone.passiveAggressive
        case .sarcastic:
            return Theme.Colors.Tone.sarcastic
        }
    }
}

extension HistoryItem {
    
    enum AnalysisType: String, Codable {
        case explain
        case reply
    }
    
    enum Tone: String, Codable {
        case anxious = "Anxious"
        case condescending = "Condescending"
        case overEager = "Over-Eager"
        case passiveAggressive = "Passive-Aggressive"
        case sarcastic = "Sarcastic"
    }
}
