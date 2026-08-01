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

        init(selectedLanguage: LanguageChoice = .english) {
            self.selectedLanguage = selectedLanguage
        }
    }
}
