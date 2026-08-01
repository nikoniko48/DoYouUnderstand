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

    // Decided once per launch (honoring the debug override below), then
    // driven purely by app state afterward - so finishing onboarding always
    // moves forward into the app, even on a debug build that always starts
    // on onboarding.
    @State private var isShowingOnboarding = ContentView.initialShouldShowOnboarding()

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
                case .themeSettings:
                    ThemeSettingsScreen { output in
                        router.handle(.themeSettings(output))
                    }
                case .languageSettings:
                    LanguageSettingsScreen { output in
                        router.handle(.languageSettings(output))
                    }
                case .privacyPolicy:
                    PrivacyPolicyScreen { output in
                        router.handle(.privacyPolicy(output))
                    }
                case .profile:
                    ProfileScreen { output in
                        router.handle(.profile(output))
                    }
                case .manageSubscription:
                    ManageSubscriptionScreen { output in
                        router.handle(.manageSubscription(output))
                    }
                }
            }
        }
        .preferredColorScheme(ThemeManager.shared.appTheme.colorScheme)
    }
}

// MARK: - Root & Onboarding -

extension ContentView {

    private static func initialShouldShowOnboarding() -> Bool {
#if DEBUG
        if debugAlwaysShowOnboarding {
            return true
        }
#endif
        return !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    @ViewBuilder
    private var rootScreen: some View {
        if isShowingOnboarding {
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
            // No payments yet - choosing a plan just completes onboarding
            // and drops the user into the app.
            hasSeenOnboarding = true
            isShowingOnboarding = false
            router.popToRoot()
        }
    }
}

#Preview {
    ContentView()
}
