//
//  DashboardStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

extension DashboardViewModel {
    
    @Observable
    final class StateModel: StateModelProtocol {
        var history: [HistoryItem]

        init(history: [HistoryItem] = []) {
            self.history = history
        }
    }
}

