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
    private let historyService: HistoryServiceProtocol

    init(historyService: HistoryServiceProtocol = HistoryServiceProvider.shared, output: @escaping (Output) -> Void) {
        self.historyService = historyService
        self.output = output
        self.stateModel = StateModel()
        loadHistory()
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
        var onDeleteHistoryItem: ((HistoryItem) -> Void)?
        var onRefresh: (() -> Void)?

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

        actions.onDeleteHistoryItem = { [weak self] item in
            self?.deleteHistoryItem(item)
        }

        actions.onRefresh = { [weak self] in
            self?.loadHistory()
        }
    }
}

// MARK: - Functions -

extension DashboardViewModel {

    private func loadHistory() {
        stateModel.history = historyService.fetchAll().map(HistoryItem.init)
        stateModel.scansRemaining = 7 // TODO: Wire to real usage/subscription quota once that's built.
        state = .loaded(stateModel)
    }

    private func deleteHistoryItem(_ item: HistoryItem) {
        historyService.delete(id: item.id)
        withAnimation(.easeInOut(duration: 0.2)) {
            stateModel.history.removeAll { $0.id == item.id }
        }
    }
}
