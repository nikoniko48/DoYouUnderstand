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
            DashboardScreen { output in
                router.handle(.dashboard(output))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .onboarding:
                    OnboardingScreen()
                case .dashboard:
                    DashboardScreen { output in
                        router.handle(.dashboard(output))
                    }
                case .input:
                    InputScreen { output in
                        router.handle(.input(output))
                    }
                case .explenation:
                    ExplanationScreen { output in
                        router.handle(.explanation(output))
                    }
                case .reply:
                    ReplyScreen { output in
                        router.handle(.reply(output))
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
