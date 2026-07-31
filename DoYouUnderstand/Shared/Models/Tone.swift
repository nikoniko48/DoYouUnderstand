//
//  Tone.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

import SwiftUI

enum Tone: String, Codable, CaseIterable {
    case anxious = "Anxious"
    case condescending = "Condescending"
    case overEager = "Over-Eager"
    case passiveAggressive = "Passive-Aggressive"
    case sarcastic = "Sarcastic"
    case professional = "Professional"
    case assertive = "Assertive"
    case friendly = "Friendly"
    case playful = "Playful"
    case apologetic = "Apologetic"
    case empathetic = "Empathetic"
    case blunt = "Blunt"
    case flirty = "Flirty"
    case diplomatic = "Diplomatic"
    case dismissive = "Dismissive"
}

// MARK: - UI Mapping
extension Tone {

    var color: Color {
        switch self {
        case .anxious: return Theme.Colors.Tone.anxious
        case .condescending: return Theme.Colors.Tone.condescending
        case .overEager: return Theme.Colors.Tone.overEager
        case .passiveAggressive: return Theme.Colors.Tone.passiveAggressive
        case .sarcastic: return Theme.Colors.Tone.sarcastic
        case .professional: return Theme.Colors.Tone.professional
        case .assertive: return Theme.Colors.Tone.assertive
        case .friendly: return Theme.Colors.Tone.friendly
        case .playful: return Theme.Colors.Tone.playful
        case .apologetic: return Theme.Colors.Tone.apologetic
        case .empathetic: return Theme.Colors.Tone.empathetic
        case .blunt: return Theme.Colors.Tone.blunt
        case .flirty: return Theme.Colors.Tone.flirty
        case .diplomatic: return Theme.Colors.Tone.diplomatic
        case .dismissive: return Theme.Colors.Tone.dismissive
        }
    }

    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .condescending: return "🧐"
        case .overEager: return "🤩"
        case .passiveAggressive: return "🙃"
        case .sarcastic: return "😏"
        case .professional: return "💼"
        case .assertive: return "⚡️"
        case .friendly: return "😊"
        case .playful: return "😄"
        case .apologetic: return "🙏"
        case .empathetic: return "🤗"
        case .blunt: return "🎯"
        case .flirty: return "😉"
        case .diplomatic: return "🤝"
        case .dismissive: return "😑"
        }
    }

    var replyTitle: String {
        switch self {
        case .anxious: return "Cautious & Reassuring"
        case .condescending: return "Firm & Superior"
        case .overEager: return "Enthusiastic & Eager"
        case .passiveAggressive: return "Polite but Pointed"
        case .sarcastic: return "Sarcastic & Snarky"
        case .professional: return "Professional & Polite"
        case .assertive: return "Assertive & Direct"
        case .friendly: return "Casual & Friendly"
        case .playful: return "Playful & Witty"
        case .apologetic: return "Apologetic & Humble"
        case .empathetic: return "Warm & Empathetic"
        case .blunt: return "Blunt & To-the-Point"
        case .flirty: return "Flirty & Charming"
        case .diplomatic: return "Diplomatic & Balanced"
        case .dismissive: return "Cold & Dismissive"
        }
    }

    /// Tweak-slider label for the "toned down" end (0.0).
    var tweakLowLabel: String {
        switch self {
        case .anxious: return "Calmer & Confident"
        case .condescending: return "More Humble"
        case .overEager: return "More Chill"
        case .passiveAggressive: return "More Direct"
        case .sarcastic: return "More Sincere"
        case .professional: return "Lighter & Friendly"
        case .assertive: return "Softer & Diplomatic"
        case .friendly: return "More Reserved"
        case .playful: return "More Serious"
        case .apologetic: return "Less Apologetic"
        case .empathetic: return "More Matter-of-Fact"
        case .blunt: return "Softer & Gentler"
        case .flirty: return "Less Flirty"
        case .diplomatic: return "More Opinionated"
        case .dismissive: return "Warmer & Engaged"
        }
    }

    /// Tweak-slider label for the "amplified" end (1.0).
    var tweakHighLabel: String {
        switch self {
        case .anxious: return "Even More Anxious"
        case .condescending: return "Even More Condescending"
        case .overEager: return "Even More Eager"
        case .passiveAggressive: return "Even More Passive-Aggressive"
        case .sarcastic: return "Even More Sarcastic"
        case .professional: return "Ultra Formal"
        case .assertive: return "Extremely Firm"
        case .friendly: return "Extra Warm & Casual"
        case .playful: return "Extra Playful"
        case .apologetic: return "Deeply Remorseful"
        case .empathetic: return "Extra Compassionate"
        case .blunt: return "Even Blunter"
        case .flirty: return "Extra Flirty"
        case .diplomatic: return "Ultra Neutral"
        case .dismissive: return "Even Colder"
        }
    }
}
