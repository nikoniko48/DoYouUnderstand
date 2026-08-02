//
//  LanguageSettingsStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

extension LanguageSettingsViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var selectedLanguage: LanguageChoice
        var selectedReplyLanguage: ReplyLanguage

        init(selectedLanguage: LanguageChoice = .english, selectedReplyLanguage: ReplyLanguage = .autoDetect) {
            self.selectedLanguage = selectedLanguage
            self.selectedReplyLanguage = selectedReplyLanguage
        }
    }
}
