//
//  ReplyLanguagePreferenceStore.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 02/08/2026.
//

import Foundation

/// The user's default output language for AI-generated replies, set from
/// Settings > Language and persisted on-device. This is the language used
/// for the initial reply batch and any new on-demand tone; a per-card
/// language toggle on the Reply screen can override it for that session
/// only, without ever writing back here.
@Observable
final class ReplyLanguagePreferenceStore {

    static let shared = ReplyLanguagePreferenceStore()

    private static let storageKey = "defaultReplyLanguage"

    var defaultReplyLanguage: ReplyLanguage {
        didSet { UserDefaults.standard.set(defaultReplyLanguage.rawValue, forKey: Self.storageKey) }
    }

    private init() {
        self.defaultReplyLanguage = UserDefaults.standard.string(forKey: Self.storageKey)
            .flatMap(ReplyLanguage.init(rawValue:)) ?? .autoDetect
    }
}
