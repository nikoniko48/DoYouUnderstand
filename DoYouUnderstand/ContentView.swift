//
//  ContentView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 08/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var router = NavigationManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        NavigationStack(path: $router.path) {
            rootScreen
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .onboarding:
                    OnboardingScreen { output in
                        handleOnboarding(output)
                    }
                case .dashboard:
                    DashboardScreen { output in
                        router.handle(.dashboard(output))
                    }
                case .input:
                    InputScreen { output in
                        router.handle(.input(output))
                    }
                case .explenation(let id):
                    ExplanationScreen(historyItemId: id) { output in
                        router.handle(.explanation(output))
                    }
                case .reply(let id):
                    ReplyScreen(historyItemId: id) { output in
                        router.handle(.reply(output))
                    }
                }
            }
        }
    }
}

// MARK: - Root & Onboarding -

extension ContentView {

    @ViewBuilder
    private var rootScreen: some View {
        if hasSeenOnboarding {
            DashboardScreen { output in
                router.handle(.dashboard(output))
            }
        } else {
            OnboardingScreen { output in
                handleOnboarding(output)
            }
        }
    }

    private func handleOnboarding(_ output: OnboardingViewModel.Output) {
        switch output {
        case .finishOnboarding:
            hasSeenOnboarding = true
            router.popToRoot()
        }
    }
}

#Preview {
    ContentView()
}
