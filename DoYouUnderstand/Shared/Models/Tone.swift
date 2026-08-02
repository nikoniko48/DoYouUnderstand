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
    case savage = "Savage"
}

extension Tone {
    /// Five highly-contrasting default tones requested for the very first
    /// reply-generation batch - picked so the initial result already reads
    /// as varied, without waiting on a full 16-tone Gemini call. Any
    /// remaining tone is generated later, on demand, from the Reply screen.
    static let initialReplyBatch: [Tone] = [.professional, .assertive, .friendly, .diplomatic, .empathetic]
}

// MARK: - UI Mapping
extension Tone {

    /// Localized display name - `rawValue` itself must stay the fixed
    /// English tone name (it's sent to/decoded from the Gemini Edge
    /// Function and used as a `Codable` key), so any UI that shows the
    /// tone's name to the user should read this instead of `rawValue`.
    var displayName: String { Loc.t(rawValue) }

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
        case .savage: return Theme.Colors.Tone.savage
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
        case .savage: return "😈"
        }
    }

    var replyTitle: String {
        switch self {
        case .anxious: return Loc.t("Cautious & Reassuring")
        case .condescending: return Loc.t("Firm & Superior")
        case .overEager: return Loc.t("Enthusiastic & Eager")
        case .passiveAggressive: return Loc.t("Polite but Pointed")
        case .sarcastic: return Loc.t("Sarcastic & Snarky")
        case .professional: return Loc.t("Professional & Polite")
        case .assertive: return Loc.t("Assertive & Direct")
        case .friendly: return Loc.t("Casual & Friendly")
        case .playful: return Loc.t("Playful & Witty")
        case .apologetic: return Loc.t("Apologetic & Humble")
        case .empathetic: return Loc.t("Warm & Empathetic")
        case .blunt: return Loc.t("Blunt & To-the-Point")
        case .flirty: return Loc.t("Flirty & Charming")
        case .diplomatic: return Loc.t("Diplomatic & Balanced")
        case .dismissive: return Loc.t("Cold & Dismissive")
        case .savage: return Loc.t("Savage & Unfiltered")
        }
    }

    /// Tweak-slider label for the "toned down" end (0.0).
    var tweakLowLabel: String {
        switch self {
        case .anxious: return Loc.t("Calmer & Confident")
        case .condescending: return Loc.t("More Humble")
        case .overEager: return Loc.t("More Chill")
        case .passiveAggressive: return Loc.t("More Direct")
        case .sarcastic: return Loc.t("More Sincere")
        case .professional: return Loc.t("Lighter & Friendly")
        case .assertive: return Loc.t("Softer & Diplomatic")
        case .friendly: return Loc.t("More Reserved")
        case .playful: return Loc.t("More Serious")
        case .apologetic: return Loc.t("Less Apologetic")
        case .empathetic: return Loc.t("More Matter-of-Fact")
        case .blunt: return Loc.t("Softer & Gentler")
        case .flirty: return Loc.t("Less Flirty")
        case .diplomatic: return Loc.t("More Opinionated")
        case .dismissive: return Loc.t("Warmer & Engaged")
        case .savage: return Loc.t("Less Savage")
        }
    }

    /// Tweak-slider label for the "amplified" end (1.0).
    var tweakHighLabel: String {
        switch self {
        case .anxious: return Loc.t("Even More Anxious")
        case .condescending: return Loc.t("Even More Condescending")
        case .overEager: return Loc.t("Even More Eager")
        case .passiveAggressive: return Loc.t("Even More Passive-Aggressive")
        case .sarcastic: return Loc.t("Even More Sarcastic")
        case .professional: return Loc.t("Ultra Formal")
        case .assertive: return Loc.t("Extremely Firm")
        case .friendly: return Loc.t("Extra Warm & Casual")
        case .playful: return Loc.t("Extra Playful")
        case .apologetic: return Loc.t("Deeply Remorseful")
        case .empathetic: return Loc.t("Extra Compassionate")
        case .blunt: return Loc.t("Even Blunter")
        case .flirty: return Loc.t("Extra Flirty")
        case .diplomatic: return Loc.t("Ultra Neutral")
        case .dismissive: return Loc.t("Even Colder")
        case .savage: return Loc.t("Brutally Savage")
        }
    }

    /// One-line explanation of what this tone generally signals in a
    /// message - shown on the Explanation screen's tone-definition tile.
    var definition: String {
        switch self {
        case .anxious: return Loc.t("The sender sounds worried or on edge, often over-explaining or seeking reassurance.")
        case .condescending: return Loc.t("The sender is talking down to you, implying they know better.")
        case .overEager: return Loc.t("The sender is overly enthusiastic, possibly masking pressure to please.")
        case .passiveAggressive: return Loc.t("The sender is indirectly expressing frustration instead of stating it outright.")
        case .sarcastic: return Loc.t("The sender means the opposite of what's literally said, often to mock or vent.")
        case .professional: return Loc.t("The sender is keeping things formal and businesslike, with no strong emotion.")
        case .assertive: return Loc.t("The sender is stating their position directly and confidently, no hedging.")
        case .friendly: return Loc.t("The sender is warm and casual, aiming to keep things comfortable.")
        case .playful: return Loc.t("The sender is joking around, not meant to be taken too seriously.")
        case .apologetic: return Loc.t("The sender feels at fault and is trying to smooth things over.")
        case .empathetic: return Loc.t("The sender is prioritizing your feelings and trying to connect emotionally.")
        case .blunt: return Loc.t("The sender is stating things plainly, with little concern for softening it.")
        case .flirty: return Loc.t("The sender is signaling romantic or playful interest.")
        case .diplomatic: return Loc.t("The sender is carefully balancing honesty with not causing offense.")
        case .dismissive: return Loc.t("The sender seems disengaged or uninterested in continuing the conversation.")
        case .savage: return Loc.t("The sender is being ruthlessly blunt or cutting, often for comedic or dominance effect.")
        }
    }
}
