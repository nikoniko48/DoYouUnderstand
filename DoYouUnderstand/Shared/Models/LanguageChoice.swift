//
//  LanguageChoice.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// Drives the app's actual display language via `LocalizationManager` (see
/// that file) - independent of `ReplyLanguage`, which only controls the
/// language Gemini writes replies in. All nine cases have real translations
/// in `Localizable.xcstrings`.
enum LanguageChoice: String, CaseIterable, Identifiable {
    case english
    case spanish
    case french
    case german
    case polish
    case portuguese
    case japanese
    case korean
    case chinese

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .polish: return "Polski"
        case .portuguese: return "Português"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .chinese: return "中文"
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
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .chinese: return "🇨🇳"
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
        case .japanese: return "ja"
        case .korean: return "ko"
        case .chinese: return "zh-Hans"
        }
    }
}
