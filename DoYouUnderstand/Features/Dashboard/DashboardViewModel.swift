//
//  DashboardViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

@Observable
final class DashboardViewModel {
    
    var state: ViewState<StateModel> = .loading
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    
    // maybe update later
    private var useMocks: Bool
    
    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
        self.useMocks = useMocks
        self.output = output
        getHistoryItems()
        setActions()
    }
}

extension DashboardViewModel {
    
    enum Output {
        case input
        case explanation
        case response
    }
}

extension DashboardViewModel {
    
    struct Actions {
        var onNavigate: ((Route) -> Void)?
        
        enum Tap {
            
        }
        
        enum Route {
            case input
            case explanation
            case response
        }
    }
    
    func setActions() {
        
        actions.onNavigate = { [weak self] route in
            switch route {
            case .input:
                self?.output(.input)
            case .explanation:
                break
            case .response:
                break
            }
        }
    }
}

extension DashboardViewModel {
    
    private func getHistoryItems() {
        guard !useMocks else {
            let mockStateModel = StateModel(
                history: HistoryItem.mockList,
                scansRemaining: 7
            )
            self.state = .loaded(mockStateModel)
            return
        }
        
        // TODO: Live implementation
    }
}
