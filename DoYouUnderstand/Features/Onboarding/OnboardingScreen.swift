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
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.currentStep)
        }
    }
}

// MARK: - Header -

extension OnboardingScreen.ContentView {

    private var header: some View {
        VStack(alignment: .leading, spacing: .space16) {
            HStack(spacing: .space16) {
                if stateModel.currentStep > 0 {
                    Button {
                        actions.onBack?()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(Theme.Typography.bodyText)
                            .scaleEffect(1.2)
                            .foregroundStyle(Theme.Colors.Text.highlight)
                            .frame(width: StaticData.Layout.backButtonSize.width, height: StaticData.Layout.backButtonSize.height)
                            .background(Theme.Colors.Main.cardSurface)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                            )
                    }
                }

                OnboardingScreen.OnboardingProgressBar(totalSteps: stateModel.totalSteps, currentStep: stateModel.currentStep)
            }

            Text("STEP \(stateModel.currentStep + 1) OF \(stateModel.totalSteps)")
                .font(Theme.Typography.badgeLabel)
                .foregroundStyle(Theme.Colors.Text.muted)
        }
    }
}

// MARK: - Step Content -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var stepContent: some View {
        switch stateModel.step {
        case .triggerTone:
            OnboardingScreen.TriggerToneStepView(stateModel: stateModel, actions: actions)
        case .copingStyle:
            OnboardingScreen.CopingStyleStepView(stateModel: stateModel, actions: actions)
        case .finisher:
            OnboardingScreen.FinisherStepView()
        }
    }
}

// MARK: - Footer -

extension OnboardingScreen.ContentView {

    @ViewBuilder
    private var footer: some View {
        if stateModel.isFinisherStep {
            Button {
                actions.onFinish?()
            } label: {
                Text("ARM YOURSELF")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Theme.Colors.Main.primary, Theme.Colors.Main.primaryGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .shadow(color: Theme.Colors.Main.accent.opacity(0.4), radius: 16, x: 0, y: 8)
            }
        } else {
            Button {
                actions.onNext?()
            } label: {
                Text("Continue")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(stateModel.isContinueEnabled ? .white : .white.opacity(0.8))
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

// MARK: - Step Views -

extension OnboardingScreen {

    struct TriggerToneStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("Which tone triggers you the most?")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.TriggerTone.allCases) { tone in
                        OnboardingOptionRow(
                            emoji: tone.emoji,
                            title: tone.rawValue,
                            isSelected: stateModel.selectedTriggerTone == tone
                        ) {
                            actions.onSelectTriggerTone?(tone)
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
                            emoji: style.emoji,
                            title: style.rawValue,
                            isSelected: stateModel.selectedCopingStyle == style
                        ) {
                            actions.onSelectCopingStyle?(style)
                        }
                    }
                }
            }
        }
    }

    struct FinisherStepView: View {

        var body: some View {
            VStack(spacing: .space24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.Colors.Main.primary, Theme.Colors.Main.primaryGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(color: Theme.Colors.Main.accent.opacity(0.5), radius: 24, x: 0, y: 12)

                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("YOU'RE READY")
                    .font(Theme.Typography.hugeTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .multilineTextAlignment(.center)

                Text("The days of second-guessing are over. Get the subtext, craft the perfect response, and hit send with zero regrets.")
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .space16)
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
                    Capsule()
                        .fill(index <= currentStep ? Theme.Colors.Main.accent : Theme.Colors.Main.cardSurface)
                        .frame(height: StaticData.Layout.progressBarHeight)
                        .overlay(
                            Capsule()
                                .stroke(Theme.Colors.Main.borderSubtle, lineWidth: index <= currentStep ? 0 : 1)
                        )
                        .shadow(
                            color: index <= currentStep ? Theme.Colors.Main.accent.opacity(0.6) : .clear,
                            radius: 6, x: 0, y: 0
                        )
                }
            }
        }
    }

    struct OnboardingOptionRow: View {

        let emoji: String
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    Text(emoji)
                        .font(.system(size: 22))
                        .frame(width: StaticData.Layout.optionEmojiBadgeSize, height: StaticData.Layout.optionEmojiBadgeSize)
                        .background(Theme.Colors.Main.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: .space12))

                    Text(title)
                        .font(Theme.Typography.bodyText.weight(.semibold))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.primary : Theme.Colors.Text.title)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(isSelected ? Theme.Colors.Main.primary : Theme.Colors.Main.borderSubtle, lineWidth: 2)
                            .frame(width: 22, height: 22)

                        if isSelected {
                            Circle()
                                .fill(Theme.Colors.Main.primary)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.space16)
                .background(isSelected ? Theme.Colors.Main.primary.opacity(0.08) : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? Theme.Colors.Main.primary : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
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
