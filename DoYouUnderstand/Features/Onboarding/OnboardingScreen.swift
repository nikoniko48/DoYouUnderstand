//
//  OnboardingScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI

struct OnboardingScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: OnboardingViewModel

    init(output: @escaping (OnboardingViewModel.Output) -> Void) {
        self.viewModel = .init(
            useMocks: true,
            output: output
        )
    }

    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(
                stateModel: stateModel,
                actions: viewModel.actions
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension OnboardingScreen {

    struct ContentView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        // Persists across app restarts - the 24h discount window starts the
        // first time onboarding is shown and never resets once it expires.
        @AppStorage("onboardingDiscountExpiresAt") private var discountExpiresAtRaw: Double = 0
        @State private var now: Date = Date()

        var discountExpiresAt: Date {
            Date(timeIntervalSince1970: discountExpiresAtRaw)
        }

        var isDiscountActive: Bool {
            now < discountExpiresAt
        }

        var body: some View {
            VStack(spacing: .space0) {
                header

                Spacer(minLength: .space24)

                stepContent
                    .id(stateModel.currentStep)
                    .transition(.onboardingStep)

                Spacer(minLength: .space24)

                footer
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space16)
            .background(Theme.Colors.Main.background)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.currentStep)
            .onAppear {
                if discountExpiresAtRaw == 0 {
                    discountExpiresAtRaw = Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { tick in
                now = tick
            }
        }
    }
}

// MARK: - Header -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var header: some View {
        if stateModel.showsProgressHeader {
            VStack(alignment: .leading, spacing: .space16) {
                OnboardingScreen.OnboardingProgressBar(
                    totalSteps: stateModel.progressStepCount,
                    currentStep: stateModel.displayStepNumber - 1
                )

                Text("STEP \(stateModel.displayStepNumber) OF \(stateModel.progressStepCount)")
                    .font(Theme.Typography.badgeLabel)
                    .foregroundStyle(Theme.Colors.Text.muted)
            }
        }
    }
}

// MARK: - Step Content -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var stepContent: some View {
        switch stateModel.step {
        case .greeting:
            OnboardingScreen.GreetingStepView()
        case .name:
            OnboardingScreen.NameStepView(stateModel: stateModel, actions: actions)
        case .age:
            OnboardingScreen.AgeStepView(stateModel: stateModel, actions: actions)
        case .theme:
            OnboardingScreen.ThemeStepView(stateModel: stateModel, actions: actions)
        case .intro:
            OnboardingScreen.IntroStepView()
        case .triggerMessage:
            OnboardingScreen.TriggerMessageStepView(stateModel: stateModel, actions: actions)
        case .processing:
            OnboardingScreen.ProcessingStepView(message: stateModel.processingMessage)
        case .stats:
            OnboardingScreen.StatsStepView()
        case .tactileHold:
            OnboardingScreen.TactileHoldStepView(onComplete: { actions.onNext?() })
        case .privacy:
            OnboardingScreen.PrivacyStepView()
        case .finisher:
            OnboardingScreen.FinisherStepView(
                stateModel: stateModel,
                actions: actions,
                isDiscountActive: isDiscountActive,
                discountExpiresAt: discountExpiresAt,
                now: now
            )
        }
    }
}

// MARK: - Footer -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var footer: some View {
        switch stateModel.step {
        case .triggerMessage, .processing, .tactileHold:
            EmptyView()

        case .finisher:
            VStack(spacing: .space8) {
                Button {
                    actions.onFinish?()
                } label: {
                    Text("START FREE TRIAL")
                        .font(Theme.Typography.primaryButton)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.Colors.Main.accent)
                        .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                }

                Text("3 free analyses, then \(stateModel.selectedPlan.price(discountActive: isDiscountActive))\(stateModel.selectedPlan.period). Cancel anytime.")
                    .font(Theme.Typography.smallBody)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .multilineTextAlignment(.center)
            }

        default:
            Button {
                actions.onNext?()
            } label: {
                Text(stateModel.step == .greeting ? "Get Started" : "Continue")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(stateModel.isContinueEnabled ? .black : Theme.Colors.Text.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        stateModel.isContinueEnabled
                        ? Theme.Colors.Main.accent
                        : Theme.Colors.Main.cardSurface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .animation(.easeInOut, value: stateModel.isContinueEnabled)
            }
            .disabled(!stateModel.isContinueEnabled)
        }
    }
}

#Preview {
    let view = OnboardingScreen(output: { _ in })
    return view
}
