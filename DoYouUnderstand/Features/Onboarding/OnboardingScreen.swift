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
            // A hand-rolled bottom panel, not a native `.sheet` - see
            // `CheckoutSheetOverlay`'s own doc comment for why: this SDK's
            // system sheet only comes back bottom-flush at the full-height
            // `.large` detent, but the checkout step specifically needs its
            // old *partial* height back, so a real sheet can't satisfy both
            // asks at once here.
            .overlay(alignment: .bottom) {
                if isShowingCheckout {
                    OnboardingScreen.CheckoutSheetOverlay(
                        stateModel: stateModel,
                        actions: actions,
                        isDiscountActive: isDiscountActive,
                        isPresented: $isShowingCheckout
                    )
                }
            }
        }
    }
}

// MARK: - Header -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var header: some View {
        if stateModel.showsProgressHeader {
            OnboardingScreen.OnboardingProgressBar(
                totalSteps: stateModel.progressStepCount,
                currentStep: stateModel.displayStepNumber - 1
            )
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
        // A small gap above the safe area/keyboard - without it, the button
        // sits flush against whatever's directly below it, which is fine
        // against the home indicator but reads as glued-on when the Name
        // step's keyboard is up (SwiftUI's automatic keyboard avoidance
        // shrinks the available space right up to the keyboard's own top
        // edge, with no breathing room of its own).
        Group {
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

        case .theme:
            // This step re-skins the whole screen live as the user taps a
            // theme/palette option, including this button's own accent
            // tint - the plain tinted glass used everywhere else can end
            // up nearly the same color as the solid `Text.title`-filled
            // selected theme card sitting right above it, reading as
            // "blends in" rather than as a distinct button. A guaranteed-
            // contrast ring (using the same title color that's always
            // readable against this theme's own background, by definition)
            // keeps it visually separate no matter which theme is active.
            Button {
                actions.onNext?()
            } label: {
                Text("Continue")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(Theme.Colors.Main.accent.contrastingForeground)
            }
            .buttonStyle(
                LiquidGlassCTAButtonStyle(tint: Theme.Colors.Main.accent)
            )
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius, style: .continuous)
                    .stroke(Theme.Colors.Text.title.opacity(0.3), lineWidth: 1.5)
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
        .padding(.bottom, .space12)
    }
}

#Preview {
    let view = OnboardingScreen(output: { _ in })
    return view
}
