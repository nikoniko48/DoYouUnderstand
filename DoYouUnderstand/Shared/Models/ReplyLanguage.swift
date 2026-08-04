//
//  ReplyLanguage.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 02/08/2026.
//

import Foundation
import NaturalLanguage

/// The output language for AI-generated replies - separate from
/// `LanguageChoice` (which is about localizing the app's own UI copy and
/// doesn't affect generation at all). `.autoDetect` matches whatever
/// language the original incoming message is in; `.english` forces English
/// regardless of the original message's language.
enum ReplyLanguage: String, CaseIterable, Identifiable {
    case autoDetect = "Auto-detect"
    case english = "English"

    var id: String { rawValue }

    /// Localized display name - `rawValue` itself must stay the fixed
    /// English value (it's sent straight to the Gemini Edge Function as
    /// `targetLanguage`), so UI that shows this to the user reads this
    /// instead.
    var title: String { Loc.t(rawValue) }

    /// Short label for the Reply screen's compact `[ AUTO | EN ]` toggle.
    var shortCode: String {
        switch self {
        case .autoDetect: return "AUTO"
        case .english: return "EN"
        }
    }

    /// Best-effort guess at which language `text` is actually written in -
    /// used to pre-select a `ReplyOption`'s `[ AUTO | EN ]` toggle to match
    /// what that specific reply actually came back as, rather than just
    /// the (possibly `.autoDetect`) global Settings preference, which
    /// doesn't tell you anything about any one card's real language.
    static func detected(from text: String) -> ReplyLanguage {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        switch recognizer.dominantLanguage?.rawValue {
        case "en": return .english
        default: return ReplyLanguagePreferenceStore.shared.defaultReplyLanguage
        }
    }
}
