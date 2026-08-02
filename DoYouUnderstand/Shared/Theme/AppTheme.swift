//
//  AppTheme.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI
import UIKit

enum Theme {

    /// All colors are computed from `ThemeManager.shared` (not static
    /// asset-catalog lookups), so every call site below automatically
    /// re-skins - live, no relaunch needed - whenever the current
    /// `AppThemeChoice`/`TonePaletteChoice` changes.
    enum Colors {

        enum Main {
            static var background: Color { ThemeManager.shared.appTheme.background }
            static var backgroundSecondary: Color { ThemeManager.shared.appTheme.backgroundSecondary }
            static var primary: Color { ThemeManager.shared.appTheme.primary }
            static var borderSubtle: Color { ThemeManager.shared.appTheme.borderSubtle }
            static var accent: Color { ThemeManager.shared.appTheme.accent }
            static var secondaryAccent: Color { ThemeManager.shared.appTheme.secondaryAccent }
            static var cardSurface: Color { ThemeManager.shared.appTheme.cardSurface }
            static var success: Color { ThemeManager.shared.appTheme.success }
        }

        enum Text {
            static var title: Color { ThemeManager.shared.appTheme.textTitle }
            static var body: Color { ThemeManager.shared.appTheme.textBody }
            static var highlight: Color { ThemeManager.shared.appTheme.textHighlight }
            static var muted: Color { ThemeManager.shared.appTheme.textMuted }
        }

        enum Tone {
            static var anxious: Color { color(for: .anxious) }
            static var condescending: Color { color(for: .condescending) }
            static var overEager: Color { color(for: .overEager) }
            static var passiveAggressive: Color { color(for: .passiveAggressive) }
            static var sarcastic: Color { color(for: .sarcastic) }
            static var professional: Color { color(for: .professional) }
            static var assertive: Color { color(for: .assertive) }
            static var friendly: Color { color(for: .friendly) }
            static var playful: Color { color(for: .playful) }
            static var apologetic: Color { color(for: .apologetic) }
            static var empathetic: Color { color(for: .empathetic) }
            static var blunt: Color { color(for: .blunt) }
            static var flirty: Color { color(for: .flirty) }
            static var diplomatic: Color { color(for: .diplomatic) }
            static var dismissive: Color { color(for: .dismissive) }
            static var savage: Color { color(for: .savage) }

            // Explicitly module-qualified - inside this `Tone` namespace,
            // the bare name `Tone` would otherwise resolve to itself
            // (Theme.Colors.Tone) rather than the top-level `Tone` model.
            private static func color(for tone: DoYouUnderstand.Tone) -> Color {
                ThemeManager.shared.tonePalette.color(for: tone)
            }
        }
    }
    
    enum Typography {

        /// Space Grotesk (variable font) - titles, headlines, big numbers, buttons.
        static func spaceGrotesk(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("SpaceGrotesk-Light", size: size).weight(weight)
        }

        /// Inter (variable font) - body copy, labels, and other supporting text.
        static func inter(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("Inter-Regular", size: size).weight(weight)
        }

        static let heroTitle = spaceGrotesk(size: 34, weight: .black)
        static let hugeTitle = spaceGrotesk(size: 22, weight: .heavy)
        static let screenTitle = spaceGrotesk(size: 18, weight: .bold)
        static let primaryButton = spaceGrotesk(size: 17, weight: .heavy)

        // Onboarding-only scale - the funnel wants noticeably bigger,
        // punchier type than the rest of the app's denser screens.
        static let onboardingTitle = spaceGrotesk(size: 24, weight: .heavy)
        static let onboardingBody = inter(size: 16, weight: .medium)

        static let biggerText = inter(size: 14, weight: .bold)
        static let bodyText = inter(size: 13, weight: .medium)
        static let smallBody = inter(size: 12, weight: .regular)

        static let badgeLabel = inter(size: 11, weight: .heavy)
        static let tinyLabel = inter(size: 10, weight: .heavy)
    }
}

extension Color {

    /// Black or white, whichever is more readable on top of this color — for text/icons drawn over a runtime-variable background color (e.g. a tone color) that may itself be white or near-white.
    var contrastingForeground: Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.6 ? .black : .white
    }
}
