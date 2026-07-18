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
        var scansRemaining: Int
        
        init(
            history: [HistoryItem] = [],
            scansRemaining: Int = .zero
        ) {
            self.history = history
            self.scansRemaining = scansRemaining
        }
    }
}

