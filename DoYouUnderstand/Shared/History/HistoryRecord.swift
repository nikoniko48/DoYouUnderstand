//
//  HistoryRecord.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import Foundation

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
        }
    }

    var tone: Tone {
        switch payload {
        case .explanation(let payload): return payload.tone
        case .reply(let payload): return payload.tone
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
        }
    }
}

enum HistoryPayload: Hashable {
    case explanation(ExplanationViewModel.Payload)
    case reply(ReplyViewModel.Payload)
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .explanation:
            self = .explanation(try container.decode(ExplanationViewModel.Payload.self, forKey: .payload))
        case .reply:
            self = .reply(try container.decode(ReplyViewModel.Payload.self, forKey: .payload))
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
        }
    }
}
