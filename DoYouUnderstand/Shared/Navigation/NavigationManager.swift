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
    case explenation
    case response
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
        case dashboard(HomeViewModel.Output)
        case input
        case explanation
        case response
    }
    
    func handle(_ event: FlowEvent) {
        switch event {
        case .dashboard(let output):
            handleDashboard(output)
        case .input:
            break
        case .explanation:
            break
        case .response:
            break
        }
    }
    
    func handleDashboard(_ output: HomeViewModel.Output) {
        switch output {
        case .input:
            navigate(to: .input)
        case .explanation:
            navigate(to: .explenation)
        case .response:
            navigate(to: .response)
        }
    }
}
