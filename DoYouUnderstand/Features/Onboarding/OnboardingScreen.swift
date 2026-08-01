//
//  OnboardingScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import SwiftUI
import UIKit

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

        // Persists across app restarts - the 3h discount window starts the
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
                    discountExpiresAtRaw = Date().addingTimeInterval(3 * 60 * 60).timeIntervalSince1970
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { tick in
                now = tick
            }
            // The Name step's TextField has no way to resign focus itself
            // (Continue lives here in the shared footer, not in that step's
            // view) - without this, the keyboard stayed up through the
            // transition into the Age step and could obscure the gender
            // chips underneath it.
            .onChange(of: stateModel.currentStep) { _, _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(
                "Something Went Wrong",
                isPresented: Binding(
                    get: { stateModel.purchaseErrorMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.purchaseErrorMessage = nil }
                    }
                )
            ) {
                Button("OK") { stateModel.purchaseErrorMessage = nil }
            } message: {
                Text(stateModel.purchaseErrorMessage ?? "")
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
            OnboardingScreen.GreetingStepView(actions: actions)
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
                    actions.onStartTrial?()
                } label: {
                    Group {
                        if stateModel.isPurchasing {
                            ProgressView()
                                .tint(Theme.Colors.Main.accent.contrastingForeground)
                        } else {
                            Text("START FREE TRIAL")
                        }
                    }
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(Theme.Colors.Main.accent.contrastingForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.Colors.Main.accent)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                }
                .disabled(stateModel.isPurchasing)

                // "3 free analyses" was stale copy from the old visible-quota
                // usage model - that's gone now (see UsageLimiter), so this
                // no longer overpromises a specific free count.
                Text("Then \(stateModel.selectedPlan.price(discountActive: isDiscountActive))\(stateModel.selectedPlan.period). Cancel anytime.")
                    .font(Theme.Typography.smallBody)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .multilineTextAlignment(.center)

                Button {
                    actions.onRestorePurchases?()
                } label: {
                    Text("Restore Purchases")
                        .font(Theme.Typography.smallBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .underline()
                }
                .disabled(stateModel.isPurchasing)
                .padding(.top, .space4)
            }

        default:
            Button {
                actions.onNext?()
            } label: {
                Text(stateModel.step == .greeting ? "Get Started" : "Continue")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(stateModel.isContinueEnabled ? Theme.Colors.Main.accent.contrastingForeground : Theme.Colors.Text.muted)
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
