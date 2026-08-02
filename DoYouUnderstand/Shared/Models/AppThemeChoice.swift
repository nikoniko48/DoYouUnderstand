//
//  AppThemeChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI
import UIKit

/// The user's picked "vibe" - drives every neutral (non-tone) color in the
/// app via `Theme.Colors.Main`/`Theme.Colors.Text` (see `ThemeManager`).
/// Dark's values are the app's original, unchanged look; Light and Terminal
/// are new real palettes, not just decorative placeholders.
enum AppThemeChoice: String, CaseIterable, Identifiable {
    case light
    case dark
    case terminal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return Loc.t("Light")
        case .dark: return Loc.t("Dark")
        case .terminal: return Loc.t("Terminal")
        }
    }

    var subtitle: String {
        switch self {
        case .light: return Loc.t("Clean and bright")
        case .dark: return Loc.t("Easy on the eyes")
        case .terminal: return Loc.t("High-contrast hacker mode")
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .terminal: return "terminal.fill"
        }
    }

    /// The system appearance to pair with each theme. Terminal's background
    /// is black like Dark's, so it rides along on `.dark` too (keeps system
    /// chrome - status bar, keyboard, alerts - legible against it).
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .terminal: return .dark
        }
    }

    /// Small mockup swatch shown on the onboarding theme-picker card - just
    /// the real background/title colors, so the preview never drifts from
    /// what the app actually looks like.
    var previewBackground: Color { background }
    var previewForeground: Color { textTitle }

    /// The device's current Light/Dark appearance - used to seed a sensible
    /// default (in `ThemeManager` and onboarding's theme step) before the
    /// user has picked anything. Terminal is never auto-selected since it
    /// isn't a real system appearance.
    static var systemPreferred: AppThemeChoice {
        UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }
}

// MARK: - Neutral Palette -

extension AppThemeChoice {

    var background: Color {
        switch self {
        case .light: return Color(red: 0.980, green: 0.980, blue: 0.980)
        case .dark: return .black
        case .terminal: return .black
        }
    }

    var backgroundSecondary: Color {
        switch self {
        case .light: return Color(red: 0.941, green: 0.941, blue: 0.941)
        case .dark: return Color(red: 0.071, green: 0.071, blue: 0.071)
        case .terminal: return Color(red: 0.039, green: 0.071, blue: 0.039)
        }
    }

    var primary: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .terminal: return Color(red: 0.224, green: 1.0, blue: 0.078)
        }
    }

    var borderSubtle: Color {
        switch self {
        case .light: return Color.black.opacity(0.12)
        case .dark: return Color.white.opacity(0.15)
        case .terminal: return Color(red: 0.224, green: 1.0, blue: 0.078).opacity(0.25)
        }
    }

    /// Primary CTA fill. Text/icons drawn on top of it must use
    /// `.contrastingForeground` rather than a hardcoded black/white, since
    /// this flips from white (Dark) to black (Light) to green (Terminal).
    var accent: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .terminal: return Color(red: 0.224, green: 1.0, blue: 0.078)
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .light: return Color(red: 0.039, green: 0.518, blue: 0.965)
        case .dark: return Color(red: 0.039, green: 0.518, blue: 0.965)
        case .terminal: return Color(red: 0.0, green: 0.898, blue: 1.0)
        }
    }

    var cardSurface: Color {
        switch self {
        case .light: return Color(red: 0.933, green: 0.933, blue: 0.933)
        case .dark: return Color(red: 0.118, green: 0.118, blue: 0.118)
        case .terminal: return Color(red: 0.051, green: 0.090, blue: 0.051)
        }
    }

    var success: Color {
        switch self {
        case .light: return Color(red: 0.063, green: 0.725, blue: 0.506)
        case .dark: return Color(red: 0.063, green: 0.725, blue: 0.506)
        case .terminal: return Color(red: 0.224, green: 1.0, blue: 0.078)
        }
    }

    var textTitle: Color {
        switch self {
        case .light: return Color(red: 0.039, green: 0.039, blue: 0.039)
        case .dark: return .white
        case .terminal: return Color(red: 0.910, green: 1.0, blue: 0.910)
        }
    }

    var textBody: Color {
        switch self {
        case .light: return Color(red: 0.302, green: 0.302, blue: 0.302)
        case .dark: return Color(red: 0.702, green: 0.702, blue: 0.702)
        case .terminal: return Color(red: 0.725, green: 1.0, blue: 0.796)
        }
    }

    var textHighlight: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .terminal: return Color(red: 0.224, green: 1.0, blue: 0.078)
        }
    }

    var textMuted: Color {
        switch self {
        case .light: return Color(red: 0.541, green: 0.541, blue: 0.541)
        case .dark: return Color(red: 0.459, green: 0.459, blue: 0.459)
        case .terminal: return Color(red: 0.361, green: 0.561, blue: 0.420)
        }
    }
}
