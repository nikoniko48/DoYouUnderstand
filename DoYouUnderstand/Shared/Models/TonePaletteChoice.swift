//
//  TonePaletteChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

/// A tone-color palette the user can preview and pick during onboarding.
/// Picking one only previews swatches and persists a preference for now -
/// it doesn't yet re-skin `Theme.Colors.Tone` app-wide. That wiring (and the
/// real palette colors) lands separately; this just makes the choice possible.
enum TonePaletteChoice: String, CaseIterable, Identifiable {
    case classic
    case pastel
    case neon
    case mono

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return "Classic"
        case .pastel: return "Pastel"
        case .neon: return "Neon"
        case .mono: return "Mono"
        }
    }

    /// Preview bubble colors - illustrative placeholders for now.
    var swatches: [Color] {
        switch self {
        case .classic:
            return [
                Theme.Colors.Tone.anxious,
                Theme.Colors.Tone.condescending,
                Theme.Colors.Tone.overEager,
                Theme.Colors.Tone.passiveAggressive,
                Theme.Colors.Tone.sarcastic
            ]
        case .pastel:
            return [
                Color(red: 0.80, green: 0.87, blue: 1.0),
                Color(red: 1.0, green: 0.85, blue: 0.90),
                Color(red: 0.85, green: 1.0, blue: 0.88),
                Color(red: 1.0, green: 0.95, blue: 0.78),
                Color(red: 0.93, green: 0.85, blue: 1.0)
            ]
        case .neon:
            return [
                Color(red: 0.0, green: 1.0, blue: 0.85),
                Color(red: 1.0, green: 0.0, blue: 0.55),
                Color(red: 0.6, green: 1.0, blue: 0.0),
                Color(red: 1.0, green: 0.75, blue: 0.0),
                Color(red: 0.45, green: 0.3, blue: 1.0)
            ]
        case .mono:
            return [
                .white,
                Color(white: 0.78),
                Color(white: 0.56),
                Color(white: 0.34),
                Color(white: 0.12)
            ]
        }
    }
}
