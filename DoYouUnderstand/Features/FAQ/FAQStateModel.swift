//
//  FAQStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

extension FAQViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var questions: [FAQItem]

        init(questions: [FAQItem] = []) {
            self.questions = questions
        }
    }
}
