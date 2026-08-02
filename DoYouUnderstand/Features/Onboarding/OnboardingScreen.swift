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
        // Drives the paywall's checkout bottom sheet - the marketing step
        // (Finisher) itself never purchases anything directly anymore.
        @State private var isShowingCheckout = false

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
                Text(LocalizedStringKey(stateModel.purchaseErrorMessage ?? ""))
            }
            .sheet(isPresented: $isShowingCheckout) {
                OnboardingScreen.CheckoutSheetView(
                    stateModel: stateModel,
                    actions: actions,
                    isDiscountActive: isDiscountActive
                )
                .presentationDetents([.fraction(0.62), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(StaticData.Layout.cornerRadius)
                // Without an explicit opaque background here, iOS 26 gives
                // sheets their own translucent Liquid Glass chrome by
                // default - which then shows through/behind our own glass
                // CTA and card overlays as a second, uncoordinated blur
                // layer (most visible as a mismatched strip below our
                // content when it doesn't exactly fill the detent height).
                // A flat, opaque background keeps exactly one glass layer
                // in the picture: the one on our own components.
                .presentationBackground(Theme.Colors.Main.background)
                .interactiveDismissDisabled(stateModel.isPurchasing)
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

                Text(String(format: Loc.t("STEP %d OF %d"), stateModel.displayStepNumber, stateModel.progressStepCount))
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
            OnboardingScreen.GreetingStepView(stateModel: stateModel, actions: actions)
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
        case .toneDemo:
            OnboardingScreen.ToneDemoStepView()
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

        case .greeting where stateModel.isGreetingIntroPlaying:
            EmptyView()

        case .finisher:
            // Step 1 of the paywall (marketing) never purchases directly -
            // it just hands off to the checkout sheet, which owns pricing,
            // the real "Start Free Trial" purchase CTA, and all legal copy.
            Button {
                isShowingCheckout = true
            } label: {
                Text("Claim My 3-Day Free Trial")
                    .font(Theme.Typography.spaceGrotesk(size: 18, weight: .heavy))
                    .foregroundStyle(Theme.Colors.Main.accent.contrastingForeground)
            }
            .buttonStyle(
                LiquidGlassCTAButtonStyle(
                    tint: Theme.Colors.Main.accent,
                    verticalPadding: 22
                )
            )

        default:
            Button {
                actions.onNext?()
            } label: {
                Text(stateModel.step == .greeting ? "Get Started" : "Continue")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(stateModel.isContinueEnabled ? Theme.Colors.Main.accent.contrastingForeground : Theme.Colors.Text.muted)
            }
            .buttonStyle(
                LiquidGlassCTAButtonStyle(
                    tint: stateModel.isContinueEnabled ? Theme.Colors.Main.accent : Theme.Colors.Main.cardSurface,
                    isInteractive: stateModel.isContinueEnabled
                )
            )
            .disabled(!stateModel.isContinueEnabled)
            .animation(.easeInOut, value: stateModel.isContinueEnabled)
        }
    }
}

#Preview {
    let view = OnboardingScreen(output: { _ in })
    return view
}
