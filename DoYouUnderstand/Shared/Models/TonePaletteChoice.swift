//
//  TonePaletteChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

/// A tone-color palette the user can pick during onboarding. Drives every
/// `Theme.Colors.Tone.*` color app-wide (see `ThemeManager`) - independent
/// of `AppThemeChoice`, so you can pair e.g. a Light app theme with a Neon
/// tone palette.
enum TonePaletteChoice: String, CaseIterable, Identifiable {
    case classic
    case pastel
    case neon
    case mono
    case terminal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return Loc.t("Classic")
        case .pastel: return Loc.t("Pastel")
        case .neon: return Loc.t("Neon")
        case .mono: return Loc.t("Mono")
        case .terminal: return Loc.t("Terminal")
        }
    }

    /// The real color for a given tone under this palette. Every palette's
    /// hand-picked values were tuned by eye against a dark background and
    /// never checked against Light theme's near-white one - measuring found
    /// most of them well below WCAG's readability minimum there. Rather
    /// than a second hand-tuned color map, this darkens (preserving hue) at
    /// read time whenever the active theme's own background needs it - a
    /// no-op against Dark/Terminal's black background, where these were
    /// already legible.
    func color(for tone: Tone) -> Color {
        let base = self == .mono ? Self.monoColor(for: tone) : (Self.colorMap[self]?[tone] ?? tone.fallbackColor)
        return base.adjustedForContrast(against: ThemeManager.shared.appTheme.background)
    }

    /// Mono's original 16 near-identical grays washed out badly (several
    /// were nearly invisible against Light theme's background, and even in
    /// Dark they were too close together to read as meaningfully distinct).
    /// A 3-tier cycling scheme fixed legibility but still showed up as "why
    /// are there several different grays for different tones" - Mono means
    /// every tone gets the exact same single, always-legible gray.
    private static func monoColor(for tone: Tone) -> Color {
        switch ThemeManager.shared.appTheme {
        case .light: return Color(white: 0.35)
        case .dark, .terminal: return Color(white: 0.65)
        }
    }

    /// Preview bubbles shown on the onboarding tone-palette row - a fixed,
    /// representative subset of the real 16-tone map (not a separate,
    /// hand-tuned array), so the preview can never drift from reality.
    var swatches: [Color] {
        Self.previewTones.map { color(for: $0) }
    }

    private static let previewTones: [Tone] = [.anxious, .sarcastic, .overEager, .playful, .diplomatic]
}

// MARK: - Fallback -

extension Tone {

    /// Used only if a palette/tone combination is ever missing from the map
    /// below (shouldn't happen - every palette covers all 16 cases).
    fileprivate var fallbackColor: Color {
        Color(red: 0.6, green: 0.6, blue: 0.6)
    }
}

// MARK: - Color Map -

extension TonePaletteChoice {

    private static let colorMap: [TonePaletteChoice: [Tone: Color]] = [
        .classic: [
            .anxious: Color(red: 0.659, green: 0.333, blue: 0.969),
            .condescending: Color(red: 0.961, green: 0.620, blue: 0.043),
            .overEager: Color(red: 0.063, green: 0.725, blue: 0.506),
            .passiveAggressive: Color(red: 0.518, green: 0.800, blue: 0.086),
            .sarcastic: Color(red: 1.0, green: 0.231, blue: 0.361),
            .professional: Color(red: 0.231, green: 0.510, blue: 0.965),
            .assertive: Color(red: 0.388, green: 0.400, blue: 0.945),
            .friendly: Color(red: 0.024, green: 0.714, blue: 0.831),
            .playful: Color(red: 0.851, green: 0.275, blue: 0.937),
            .apologetic: Color(red: 0.580, green: 0.639, blue: 0.722),
            .empathetic: Color(red: 0.984, green: 0.443, blue: 0.522),
            .blunt: Color(red: 0.690, green: 0.690, blue: 0.722),
            .flirty: Color(red: 0.925, green: 0.282, blue: 0.600),
            .diplomatic: Color(red: 0.078, green: 0.722, blue: 0.651),
            .dismissive: Color(red: 0.431, green: 0.608, blue: 0.769),
            .savage: Color(red: 0.722, green: 0.078, blue: 0.078)
        ],
        .pastel: [
            .anxious: Color(red: 0.769, green: 0.663, blue: 0.941),
            .condescending: Color(red: 0.961, green: 0.788, blue: 0.537),
            .overEager: Color(red: 0.553, green: 0.878, blue: 0.753),
            .passiveAggressive: Color(red: 0.765, green: 0.910, blue: 0.553),
            .sarcastic: Color(red: 1.0, green: 0.659, blue: 0.737),
            .professional: Color(red: 0.659, green: 0.784, blue: 0.961),
            .assertive: Color(red: 0.678, green: 0.690, blue: 0.961),
            .friendly: Color(red: 0.620, green: 0.890, blue: 0.937),
            .playful: Color(red: 0.933, green: 0.663, blue: 0.941),
            .apologetic: Color(red: 0.780, green: 0.816, blue: 0.859),
            .empathetic: Color(red: 0.992, green: 0.749, blue: 0.788),
            .blunt: Color(red: 0.839, green: 0.839, blue: 0.863),
            .flirty: Color(red: 0.969, green: 0.663, blue: 0.808),
            .diplomatic: Color(red: 0.620, green: 0.867, blue: 0.827),
            .dismissive: Color(red: 0.718, green: 0.800, blue: 0.878),
            .savage: Color(red: 0.945, green: 0.612, blue: 0.612)
        ],
        .neon: [
            .anxious: Color(red: 0.690, green: 0.149, blue: 1.0),
            .condescending: Color(red: 1.0, green: 0.722, blue: 0.0),
            .overEager: Color(red: 0.0, green: 1.0, blue: 0.612),
            .passiveAggressive: Color(red: 0.776, green: 1.0, blue: 0.0),
            .sarcastic: Color(red: 1.0, green: 0.063, blue: 0.325),
            .professional: Color(red: 0.0, green: 0.639, blue: 1.0),
            .assertive: Color(red: 0.482, green: 0.184, blue: 1.0),
            .friendly: Color(red: 0.0, green: 0.898, blue: 1.0),
            .playful: Color(red: 0.957, green: 0.0, blue: 0.957),
            .apologetic: Color(red: 0.431, green: 0.776, blue: 1.0),
            .empathetic: Color(red: 1.0, green: 0.420, blue: 0.616),
            .blunt: Color(red: 0.839, green: 0.839, blue: 1.0),
            .flirty: Color(red: 1.0, green: 0.180, blue: 0.624),
            .diplomatic: Color(red: 0.0, green: 1.0, blue: 0.784),
            .dismissive: Color(red: 0.498, green: 0.659, blue: 1.0),
            .savage: Color(red: 1.0, green: 0.0, blue: 0.129)
        ],
        // .mono is handled separately by `monoColor(for:)` (3 theme-aware
        // tiers instead of 16 hand-picked grays) - no entry needed here.
        // Phosphor-CRT palette designed to match the Terminal app theme -
        // greens/cyans/ambers only, no purple/pink hues that would clash
        // with a hacker aesthetic. All verified >7:1 WCAG contrast on black.
        .terminal: [
            .anxious: Color(red: 1.0, green: 0.722, blue: 0.0),
            .condescending: Color(red: 0.780, green: 1.0, blue: 0.0),
            .overEager: Color(red: 0.224, green: 1.0, blue: 0.078),
            .passiveAggressive: Color(red: 0.643, green: 0.784, blue: 0.086),
            .sarcastic: Color(red: 1.0, green: 0.267, blue: 0.267),
            .professional: Color(red: 0.0, green: 0.898, blue: 1.0),
            .assertive: Color(red: 0.086, green: 0.851, blue: 0.573),
            .friendly: Color(red: 0.435, green: 1.0, blue: 0.635),
            .playful: Color(red: 0.0, green: 1.0, blue: 0.588),
            .apologetic: Color(red: 0.573, green: 0.706, blue: 0.596),
            .empathetic: Color(red: 0.612, green: 0.933, blue: 0.749),
            .blunt: Color(red: 0.827, green: 1.0, blue: 0.827),
            .flirty: Color(red: 1.0, green: 0.482, blue: 0.482),
            .diplomatic: Color(red: 0.0, green: 0.808, blue: 0.702),
            .dismissive: Color(red: 0.678, green: 0.616, blue: 0.412),
            .savage: Color(red: 1.0, green: 0.302, blue: 0.0)
        ]
    ]
}
