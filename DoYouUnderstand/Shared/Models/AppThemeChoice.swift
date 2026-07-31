//
//  AppThemeChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

/// The user's onboarding "vibe" pick. Light/Dark map to a real `ColorScheme`
/// today; Terminal is selectable and persisted but has no dedicated palette
/// yet, so it intentionally falls back to the system appearance.
enum AppThemeChoice: String, CaseIterable, Identifiable {
    case light
    case dark
    case terminal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .terminal: return "Terminal"
        }
    }

    var subtitle: String {
        switch self {
        case .light: return "Clean and bright"
        case .dark: return "Easy on the eyes"
        case .terminal: return "High-contrast hacker mode"
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .terminal: return "terminal.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .terminal: return nil
        }
    }

    /// Illustrative colors for the onboarding theme-picker preview swatch -
    /// not the app's actual rendered colors (Terminal has no real palette yet).
    var previewBackground: Color {
        switch self {
        case .light: return Color(red: 0.97, green: 0.97, blue: 0.97)
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.12)
        case .terminal: return .black
        }
    }

    var previewForeground: Color {
        switch self {
        case .light: return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .dark: return .white
        case .terminal: return Color(red: 0.2, green: 1.0, blue: 0.35)
        }
    }
}
