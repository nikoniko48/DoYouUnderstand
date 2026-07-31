//
//  ContentView.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 08/06/2026.
//

import SwiftUI

#if DEBUG
/// Flip to `true` to always show onboarding on launch, regardless of `hasSeenOnboarding`.
private let debugAlwaysShowOnboarding = true
#endif

struct ContentView: View {
    @State private var router = NavigationManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("selectedAppTheme") private var selectedThemeRaw: String = AppThemeChoice.light.rawValue

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
                case .explenation(let destination):
                    ExplanationScreen(destination: destination) { output in
                        router.handle(.explanation(output))
                    }
                case .reply(let destination):
                    ReplyScreen(destination: destination) { output in
                        router.handle(.reply(output))
                    }
                case .faq:
                    FAQScreen { output in
                        router.handle(.faq(output))
                    }
                case .settings:
                    SettingsScreen { output in
                        router.handle(.settings(output))
                    }
                }
            }
        }
        .preferredColorScheme(AppThemeChoice(rawValue: selectedThemeRaw)?.colorScheme)
    }
}

// MARK: - Root & Onboarding -

extension ContentView {

    private var shouldShowOnboarding: Bool {
#if DEBUG
        if debugAlwaysShowOnboarding {
            return true
        }
#endif
        return !hasSeenOnboarding
    }

    @ViewBuilder
    private var rootScreen: some View {
        if shouldShowOnboarding {
            OnboardingScreen { output in
                handleOnboarding(output)
            }
        } else {
            DashboardScreen { output in
                router.handle(.dashboard(output))
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
