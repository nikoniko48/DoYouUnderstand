//
//  HistoryRecord.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

struct HistoryRecord: Identifiable, Hashable, Codable {
    let id: String
    let timestamp: Date
    let payload: HistoryPayload
}

extension HistoryRecord {

    var type: AnalysisType {
        switch payload {
        case .explanation: return .explain
        case .reply: return .reply
        case .refine: return .refine
        }
    }

    /// Explain/Reply's tone is always one of the fixed `Tone` cases, but
    /// Refine analyzes the user's OWN draft with a short freeform label
    /// (e.g. "Defensive & Hesitant") that isn't constrained to that
    /// taxonomy - this is the common shape the Dashboard card's tone pill
    /// renders regardless of which of the three it came from.
    var toneBadge: HistoryToneBadge {
        switch payload {
        case .explanation(let payload): return HistoryToneBadge(label: payload.tone.displayName, color: payload.tone.color)
        case .reply(let payload): return HistoryToneBadge(label: payload.tone.displayName, color: payload.tone.color)
        case .refine(let payload): return HistoryToneBadge(label: payload.tone, color: payload.colorTone.color)
        }
    }

    /// Falls back to the AI-extracted text when the user submitted an image
    /// with no typed text of their own, so the Dashboard never shows a blank
    /// preview for screenshot-only analyses.
    var snippet: String {
        switch payload {
        case .explanation(let payload):
            return payload.originalMessage.isEmpty ? payload.extractedText : payload.originalMessage
        case .reply(let payload):
            return payload.originalMessage.isEmpty ? payload.extractedText : payload.originalMessage
        case .refine(let payload):
            return payload.originalMessage
        }
    }
}

struct HistoryToneBadge: Hashable {
    let label: String
    let color: Color
}

enum HistoryPayload: Hashable {
    case explanation(ExplanationViewModel.Payload)
    case reply(ReplyViewModel.Payload)
    case refine(RefineViewModel.Payload)
}

// Enums with associated values don't get synthesized Codable, so this is written by hand.
extension HistoryPayload: Codable {

    private enum CodingKeys: String, CodingKey {
        case kind
        case payload
    }

    private enum Kind: String, Codable {
        case explanation
        case reply
        case refine
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .explanation:
            self = .explanation(try container.decode(ExplanationViewModel.Payload.self, forKey: .payload))
        case .reply:
            self = .reply(try container.decode(ReplyViewModel.Payload.self, forKey: .payload))
        case .refine:
            self = .refine(try container.decode(RefineViewModel.Payload.self, forKey: .payload))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .explanation(let payload):
            try container.encode(Kind.explanation, forKey: .kind)
            try container.encode(payload, forKey: .payload)
        case .reply(let payload):
            try container.encode(Kind.reply, forKey: .kind)
            try container.encode(payload, forKey: .payload)
        case .refine(let payload):
            try container.encode(Kind.refine, forKey: .kind)
            try container.encode(payload, forKey: .payload)
        }
    }
}
