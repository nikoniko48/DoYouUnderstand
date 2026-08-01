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

    /// One-line explanation of what this tone generally signals in a
    /// message - shown on the Explanation screen's tone-definition tile.
    var definition: String {
        switch self {
        case .anxious: return "The sender sounds worried or on edge, often over-explaining or seeking reassurance."
        case .condescending: return "The sender is talking down to you, implying they know better."
        case .overEager: return "The sender is overly enthusiastic, possibly masking pressure to please."
        case .passiveAggressive: return "The sender is indirectly expressing frustration instead of stating it outright."
        case .sarcastic: return "The sender means the opposite of what's literally said, often to mock or vent."
        case .professional: return "The sender is keeping things formal and businesslike, with no strong emotion."
        case .assertive: return "The sender is stating their position directly and confidently, no hedging."
        case .friendly: return "The sender is warm and casual, aiming to keep things comfortable."
        case .playful: return "The sender is joking around, not meant to be taken too seriously."
        case .apologetic: return "The sender feels at fault and is trying to smooth things over."
        case .empathetic: return "The sender is prioritizing your feelings and trying to connect emotionally."
        case .blunt: return "The sender is stating things plainly, with little concern for softening it."
        case .flirty: return "The sender is signaling romantic or playful interest."
        case .diplomatic: return "The sender is carefully balancing honesty with not causing offense."
        case .dismissive: return "The sender seems disengaged or uninterested in continuing the conversation."
        }
    }
}
