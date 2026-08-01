//
//  LanguageChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// UI-only for now - picking a language persists the preference but doesn't
/// localize anything yet. Wire this up to real string catalogs/`Locale` once
/// the app actually ships translated copy.
enum LanguageChoice: String, CaseIterable, Identifiable {
    case english
    case spanish
    case french
    case german
    case polish
    case portuguese

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .polish: return "Polski"
        case .portuguese: return "Português"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .polish: return "🇵🇱"
        case .portuguese: return "🇵🇹"
        }
    }
}
