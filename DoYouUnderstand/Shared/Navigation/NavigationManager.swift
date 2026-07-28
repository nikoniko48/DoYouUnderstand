//
//  NavigationManager.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

enum Route: Hashable {
    case onboarding
    case dashboard
    case input
    case explenation(String?)
    case reply(String?)
    case faq
    case settings
}

@Observable
class NavigationManager {
    
    var path = NavigationPath()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func popBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

extension NavigationManager {
    
    enum FlowEvent {
        case dashboard(DashboardViewModel.Output)
        case input(InputViewModel.Output)
        case explanation(ExplanationViewModel.Output)
        case reply(ReplyViewModel.Output)
        case faq(FAQViewModel.Output)
        case settings(SettingsViewModel.Output)
    }

    func handle(_ event: FlowEvent) {
        switch event {
        case .dashboard(let output):
            handleDashboard(output)
        case .input(let output):
            handleInput(output)
        case .explanation(let output):
            handleExplanation(output)
        case .reply(let output):
            handleReply(output)
        case .faq(let output):
            handleFAQ(output)
        case .settings(let output):
            handleSettings(output)
        }
    }

    func handleDashboard(_ output: DashboardViewModel.Output) {
        switch output {
        case .input:
            navigate(to: .input)
        case .explanation(let id):
            navigate(to: .explenation(id))
        case .reply(let id):
            navigate(to: .reply(id))
        case .faq:
            navigate(to: .faq)
        case .settings:
            navigate(to: .settings)
        }
    }
    
    func handleInput(_ output: InputViewModel.Output) {
        switch output {
        case .goBack:
            popBack()
        case .explain:
            navigate(to: .explenation(nil))
        case .reply:
            navigate(to: .reply(nil))
        }
    }
    
    func handleExplanation(_ output: ExplanationViewModel.Output) {
        switch output {
        case .goBack:
            popBack()
        }
    }
    
    func handleReply(_ output: ReplyViewModel.Output) {
        switch output {
        case .goBack:
            popBack()
        }
    }

    func handleFAQ(_ output: FAQViewModel.Output) {
        switch output {
        case .goBack:
            popBack()
        }
    }

    func handleSettings(_ output: SettingsViewModel.Output) {
        switch output {
        case .goBack:
            popBack()
        }
    }
}
