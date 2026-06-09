//
//  HistoryItem.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct HistoryItem: Identifiable, Hashable {
    let id: String
    let snippet: String
    let tone: String
    let toneColorHex: String
    let toneBgHex: String
    let timestamp: String
    let type: AnalysisType
    
    enum AnalysisType: String, Hashable {
        case explanation
        case reply
    }
}
