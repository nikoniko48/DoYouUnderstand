//
//  LanguageChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// Drives the app's actual display language via `LocalizationManager` (see
/// that file) - independent of `ReplyLanguage`, which only controls the
/// language Gemini writes replies in. Only `.english`, `.polish`, and
/// `.spanish` have real translations in `Localizable.xcstrings` today;
/// picking `.french`/`.german`/`.portuguese` falls back to English for any
/// string not yet translated (a String Catalog's normal, safe behavior for
/// a missing localization) until those are added.
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

    /// Fed to `Locale(identifier:)` by `LocalizationManager` to resolve
    /// `Localizable.xcstrings` lookups against this language specifically,
    /// regardless of the device's own system language.
    var localeIdentifier: String {
        switch self {
        case .english: return "en"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .polish: return "pl"
        case .portuguese: return "pt"
        }
    }
}
