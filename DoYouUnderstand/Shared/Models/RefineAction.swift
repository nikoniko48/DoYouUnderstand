//
//  RefineAction.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

/// The four quick-action transforms on the Refine screen. `rawValue` is the
/// exact key sent as `action` to the `analyze-message` Edge Function's
/// `refineTransform` mode (`REFINE_ACTIONS` in `index.ts`) - the two must
/// stay in sync, same convention as `Tone.rawValue` <-> the server's `TONES`.
enum RefineAction: String, CaseIterable, Identifiable, Codable {
    case fixGrammar
    case checkClarity
    case shorten
    case lengthen

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fixGrammar: return "pencil.and.outline"
        case .checkClarity: return "brain.head.profile"
        case .shorten: return "arrow.down.right.and.arrow.up.left"
        case .lengthen: return "arrow.up.left.and.arrow.down.right"
        }
    }

    var title: String {
        switch self {
        case .fixGrammar: return Loc.t("Fix Grammar & Punctuation")
        case .checkClarity: return Loc.t("Check Clarity & Sense")
        case .shorten: return Loc.t("Shorten")
        case .lengthen: return Loc.t("Lengthen")
        }
    }

    /// A specific, fixed `Theme.Colors.Tone.*` color chosen per action
    /// purely for a nice-looking icon tint - unrelated to any detected
    /// tone, just reusing the app's existing tone palette so these icons
    /// still re-skin live with `TonePaletteChoice`.
    var iconColor: Color {
        switch self {
        case .fixGrammar: return Theme.Colors.Tone.professional
        case .checkClarity: return Theme.Colors.Tone.diplomatic
        case .shorten: return Theme.Colors.Tone.assertive
        case .lengthen: return Theme.Colors.Tone.friendly
        }
    }
}
