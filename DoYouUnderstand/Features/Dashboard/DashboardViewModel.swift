//
//  DashboardViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

@Observable
final class DashboardViewModel: StateViewModelProtocol {
    
    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading
    
    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private var useMocks: Bool
    
    init(useMocks: Bool = false, output: @escaping (Output) -> Void) {
        self.useMocks = useMocks
        self.output = output
        self.stateModel = StateModel()
        getHistoryItems()
        setActions()
    }
}

// MARK: - Output -

extension DashboardViewModel {
    
    enum Output {
        case input
        case explanation(String) // ✅ Pass ID
        case reply(String)       // ✅ Pass ID
        case faq
        case settings
    }
}

// MARK: - Actions -

extension DashboardViewModel {
    
    struct Actions {
        var onNavigate: ((Route) -> Void)?
        var onTapHistoryItem: ((HistoryItem) -> Void)? // ✅ Handle item taps
        
        enum Route {
            case input
            case faq
            case settings
        }
    }

    func setActions() {

        actions.onNavigate = { [weak self] route in
            switch route {
            case .input:
                self?.output(.input)
            case .faq:
                self?.output(.faq)
            case .settings:
                self?.output(.settings)
            }
        }
        
        actions.onTapHistoryItem = { [weak self] item in
            // Route based on the type of history item
            switch item.type {
            case .explain:
                self?.output(.explanation(item.id))
            case .reply:
                self?.output(.reply(item.id))
            }
        }
    }
}

// MARK: - Functions -

extension DashboardViewModel {
    private func getHistoryItems() {
        if useMocks {
            stateModel.history = HistoryItem.mockList
            stateModel.scansRemaining = 7
            state = .loaded(stateModel)
        } else {
            // TODO: Fetch from Supabase/CloudKit
        }
    }
}
