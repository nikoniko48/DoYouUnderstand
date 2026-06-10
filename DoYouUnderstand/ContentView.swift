//
//  ContentView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 08/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var router = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            DashboardView { output in
                router.handle(.dashboard(output))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .onboarding:
                    OnboardingView()
                case .dashboard:
                    DashboardView { output in
                        router.handle(.dashboard(output))
                    }
                case .input:
                    InputView()
                case .explenation:
                    ExplanationView()
                case .response:
                    ResponseView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
