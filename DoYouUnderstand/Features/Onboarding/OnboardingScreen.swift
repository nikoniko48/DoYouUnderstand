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
                    .transition(.onboardingStepForward)

                Spacer(minLength: .space24)

                footer
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space16)
            .background(Theme.Colors.Main.background)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.currentStep)
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.width > 50 && stateModel.currentStep > 0 {
                        actions.onSwipeBack?()
                    }
                }
            )
        }
    }
}

// MARK: - Header -

extension OnboardingScreen.ContentView {

    private var header: some View {
        VStack(alignment: .leading, spacing: .space16) {
            OnboardingScreen.OnboardingProgressBar(totalSteps: stateModel.totalSteps, currentStep: stateModel.currentStep)

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
        case .communicationContext:
            OnboardingScreen.CommunicationContextStepView(stateModel: stateModel, actions: actions)
        case .goal:
            OnboardingScreen.GoalStepView(stateModel: stateModel, actions: actions)
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
                Text("START DECODING")
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.Colors.Main.accent)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            }
        } else {
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
        }
    }
}

// MARK: - Step Views -

extension OnboardingScreen {

    struct CommunicationContextStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("Where do you encounter the most confusing communication?")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.CommunicationContext.allCases) { context in
                        OnboardingOptionRow(
                            title: context.rawValue,
                            isSelected: stateModel.selectedContext == context
                        ) {
                            actions.onSelectContext?(context)
                        }
                    }
                }
            }
        }
    }

    struct GoalStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("What is your ultimate goal here?")
                    .font(Theme.Typography.screenTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                VStack(spacing: .space12) {
                    ForEach(OnboardingViewModel.StateModel.Goal.allCases) { goal in
                        OnboardingOptionRow(
                            title: goal.rawValue,
                            isSelected: stateModel.selectedGoal == goal
                        ) {
                            actions.onSelectGoal?(goal)
                        }
                    }
                }
            }
        }
    }

    struct FinisherStepView: View {

        var body: some View {
            VStack(alignment: .leading, spacing: .space16) {
                Text("No more second-guessing.")
                    .font(Theme.Typography.hugeTitle)
                    .foregroundStyle(Theme.Colors.Text.title)

                Text("Navigate every tricky conversation with absolute clarity.")
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(Theme.Colors.Text.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    Text(title)
                        .font(Theme.Typography.bodyText.weight(.semibold))
                        .foregroundStyle(isSelected ? .black : Theme.Colors.Text.title)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(Theme.Typography.bodyText.weight(.bold))
                            .foregroundStyle(.black)
                    }
                }
                .padding(.space16)
                .background(isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle,
                            lineWidth: 1
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
}

#Preview {
    let view = OnboardingScreen(output: { _ in })
    return view
}
