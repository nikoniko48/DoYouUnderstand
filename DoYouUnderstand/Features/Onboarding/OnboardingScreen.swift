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
                    .transition(
                        stateModel.direction == .forward
                        ? .onboardingStepForward
                        : .onboardingStepBackward
                    )

                Spacer(minLength: .space24)

                footer
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space16)
            .background(Theme.Colors.Main.background)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.currentStep)
            .gesture(
                DragGesture().onEnded { value in
                    guard stateModel.canSwipeBack else { return }
                    if value.translation.width > 50 && stateModel.currentStep > 0 {
                        actions.onSwipeBack?()
                    }
                }
            )
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
                    currentStep: min(stateModel.currentStep, stateModel.progressStepCount - 1)
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
        case .triggerMessage:
            OnboardingScreen.TriggerMessageStepView(stateModel: stateModel, actions: actions)
        case .copingStyle:
            OnboardingScreen.CopingStyleStepView(stateModel: stateModel, actions: actions)
        case .processing:
            OnboardingScreen.ProcessingStepView(message: stateModel.processingMessage)
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
        case .triggerMessage, .copingStyle, .privacy:
            Button {
                actions.onNext?()
            } label: {
                Text("Continue")
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

        case .processing:
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
        }
    }
}

// MARK: - Step Views -

extension OnboardingScreen {

    struct TriggerMessageStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("Which type of message triggers you the most?")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.TriggerMessage.allCases) { message in
                        OnboardingOptionRow(
                            icon: message.icon,
                            title: message.rawValue,
                            subtitle: message.subtitle,
                            toneColor: message.toneColor,
                            isSelected: stateModel.selectedTriggerMessage == message
                        ) {
                            actions.onSelectTriggerMessage?(message)
                        }
                    }
                }
            }
        }
    }

    struct CopingStyleStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("How do you usually handle a tricky text or email?")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.CopingStyle.allCases) { style in
                        OnboardingOptionRow(
                            icon: style.icon,
                            title: style.rawValue,
                            subtitle: style.subtitle,
                            toneColor: style.toneColor,
                            isSelected: stateModel.selectedCopingStyle == style
                        ) {
                            actions.onSelectCopingStyle?(style)
                        }
                    }
                }
            }
        }
    }

    struct ProcessingStepView: View {

        let message: String

        var body: some View {
            VStack(spacing: .space24) {
                Spacer(minLength: .space0)

                ProgressView()
                    .tint(Theme.Colors.Main.accent)
                    .scaleEffect(1.8)

                VStack(spacing: .space8) {
                    Text("Calibrating your communication profile...")
                        .font(Theme.Typography.screenTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .multilineTextAlignment(.center)
                        .id(message)
                        .transition(.opacity)
                }
                .padding(.horizontal, .space24)

                Spacer(minLength: .space0)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct Feature: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let toneColor: Color
    }

    struct PrivacyStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "lock.fill", text: "Processed securely, then forgotten by our servers", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "internaldrive.fill", text: "Your history lives only on this device", toneColor: Theme.Colors.Tone.anxious),
            Feature(icon: "xmark.icloud.fill", text: "Zero cloud databases - nothing to breach or sell", toneColor: Theme.Colors.Tone.condescending)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(alignment: .leading, spacing: .space12) {
                    Text("Your messages never leave your pocket.")
                        .font(Theme.Typography.hugeTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("This app runs on a local-first architecture. No account, no sign-up, no server-side profile of you.")
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(4)
                }

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Self.points) { point in
                        FinisherFeatureRow(icon: point.icon, text: point.text, toneColor: point.toneColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct FinisherStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions
        let isDiscountActive: Bool
        let discountExpiresAt: Date
        let now: Date

        private var remainingTimeString: String {
            let remaining = max(0, Int(discountExpiresAt.timeIntervalSince(now)))
            let hours = remaining / 3600
            let minutes = (remaining % 3600) / 60
            let seconds = remaining % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        private static let features: [OnboardingScreen.Feature] = [
            Feature(icon: "magnifyingglass", text: "Decode hidden meanings", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "shield.fill", text: "Set firm boundaries", toneColor: Theme.Colors.Tone.passiveAggressive),
            Feature(icon: "bolt.fill", text: "Generate bulletproof replies", toneColor: Theme.Colors.Tone.sarcastic)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("PROFILE COMPLETE")
                    .font(Theme.Typography.badgeLabel)
                    .foregroundStyle(Theme.Colors.Tone.anxious)
                    .padding(.horizontal, .space12)
                    .padding(.vertical, .space6)
                    .background(Theme.Colors.Tone.anxious.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Theme.Colors.Tone.anxious.opacity(0.4), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: .space12) {
                    Text("The days of second-guessing are over.")
                        .font(Theme.Typography.hugeTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Get the subtext, craft the perfect response, and hit send with zero regrets.")
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(4)
                }

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Self.features) { feature in
                        FinisherFeatureRow(icon: feature.icon, text: feature.text, toneColor: feature.toneColor)
                    }
                }

                // MARK: - Free Trial Callout
                HStack(spacing: .space12) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .frame(width: 40, height: 40)
                        .background(Theme.Colors.Main.accent)
                        .clipShape(RoundedRectangle(cornerRadius: .space8))

                    VStack(alignment: .leading, spacing: .space2) {
                        Text("3 FREE USES")
                            .font(Theme.Typography.badgeLabel)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text("Try it free. No credit card required.")
                            .font(Theme.Typography.smallBody)
                            .foregroundStyle(Theme.Colors.Text.muted)
                    }

                    Spacer(minLength: .space0)
                }
                .padding(.space16)
                .background(Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                )

                // MARK: - Pricing
                VStack(alignment: .leading, spacing: .space12) {
                    if isDiscountActive {
                        HStack(spacing: .space6) {
                            Image(systemName: "clock.fill")
                            Text("LIMITED OFFER ENDS IN \(remainingTimeString)")
                        }
                        .font(Theme.Typography.tinyLabel)
                        .foregroundStyle(Theme.Colors.Main.background)
                        .padding(.horizontal, .space12)
                        .padding(.vertical, .space6)
                        .background(Theme.Colors.Main.accent)
                        .clipShape(Capsule())
                    }

                    VStack(spacing: .space12) {
                        ForEach(OnboardingViewModel.StateModel.PricingPlan.allCases) { plan in
                            PricingPlanRow(
                                plan: plan,
                                isSelected: stateModel.selectedPlan == plan,
                                isDiscountActive: isDiscountActive
                            ) {
                                actions.onSelectPlan?(plan)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct PricingPlanRow: View {

        let plan: OnboardingViewModel.StateModel.PricingPlan
        let isSelected: Bool
        let isDiscountActive: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space12) {
                    VStack(alignment: .leading, spacing: .space4) {
                        HStack(spacing: .space8) {
                            Text(plan.rawValue)
                                .font(Theme.Typography.bodyText.weight(.bold))

                            if let badge = plan.badge {
                                Text(badge)
                                    .font(Theme.Typography.tinyLabel)
                                    .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Main.accent)
                                    .padding(.horizontal, .space6)
                                    .padding(.vertical, .space2)
                                    .overlay(
                                        Capsule().stroke(isSelected ? Theme.Colors.Main.background : Theme.Colors.Main.accent, lineWidth: 1)
                                    )
                            }
                        }

                        if isDiscountActive {
                            HStack(spacing: .space6) {
                                Text(plan.standardPrice)
                                    .strikethrough()
                                    .foregroundStyle(isSelected ? Theme.Colors.Main.background.opacity(0.6) : Theme.Colors.Text.muted)

                                Text("\(plan.discountedPrice)\(plan.period)")
                            }
                            .font(Theme.Typography.smallBody)
                        } else {
                            Text("\(plan.standardPrice)\(plan.period)")
                                .font(Theme.Typography.smallBody)
                        }
                    }
                    .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.space16)
                .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.borderSubtle, lineWidth: isSelected ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct FinisherFeatureRow: View {

        let icon: String
        let text: String
        let toneColor: Color

        var body: some View {
            HStack(spacing: .space12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(toneColor)
                    .frame(width: 36, height: 36)
                    .background(toneColor.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: .space8))
                    .overlay(
                        RoundedRectangle(cornerRadius: .space8)
                            .stroke(toneColor.opacity(0.4), lineWidth: 1)
                    )

                Text(text)
                    .font(Theme.Typography.bodyText.weight(.semibold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Subcomponents -

extension OnboardingScreen {

    struct OnboardingProgressBar: View {

        let totalSteps: Int
        let currentStep: Int

        var body: some View {
            HStack(spacing: .space8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Rectangle()
                        .fill(index <= currentStep ? Theme.Colors.Main.accent : Theme.Colors.Main.cardSurface)
                        .frame(height: StaticData.Layout.progressBarHeight)
                }
            }
        }
    }

    struct OnboardingOptionRow: View {

        let icon: String
        let title: String
        let subtitle: String
        let toneColor: Color
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.background : toneColor)
                        .frame(width: 44, height: 44)
                        .background(toneColor.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: .space12))

                    VStack(alignment: .leading, spacing: .space4) {
                        Text(title)
                            .font(Theme.Typography.bodyText.weight(.bold))
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(Theme.Typography.smallBody)
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background.opacity(0.7) : Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.leading)

                    Spacer(minLength: .space8)

                    // Reserved at all times (opacity-only toggle) so the title's
                    // available width — and therefore its wrap state — never
                    // changes when the row is selected.
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.space16)
                .frame(maxWidth: .infinity, minHeight: 76)
                .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? toneColor : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Transitions -

extension AnyTransition {

    static var onboardingStepForward: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    static var onboardingStepBackward: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
}

#Preview {
    let view = OnboardingScreen(output: { _ in })
    return view
}
