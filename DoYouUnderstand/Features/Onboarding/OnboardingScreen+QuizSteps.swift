//
//  OnboardingScreen+QuizSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

extension OnboardingScreen {

    struct TriggerMessageStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("Which message triggers you the most?")
                    .font(Theme.Typography.onboardingTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                VStack(spacing: .space24) {
                    ForEach(Array(OnboardingViewModel.StateModel.TriggerMessage.allCases.enumerated()), id: \.element.id) { index, message in
                        MessageBubbleOption(
                            message: message,
                            isSelected: stateModel.selectedTriggerMessage == message
                        ) {
                            actions.onSelectTriggerMessage?(message)
                        }
                        .onboardingReveal(delay: 0.1 + Double(index) * 0.1)
                    }
                }
            }
        }
    }

    struct MessageBubbleOption: View {

        let message: OnboardingViewModel.StateModel.TriggerMessage
        let isSelected: Bool
        let action: () -> Void

        private var bubbleShape: UnevenRoundedRectangle {
            .rect(topLeadingRadius: 18, bottomLeadingRadius: 4, bottomTrailingRadius: 18, topTrailingRadius: 18)
        }

        var body: some View {
            Button(action: action) {
                VStack(alignment: .leading, spacing: .space6) {
                    Text(message.senderLabel)
                        .font(Theme.Typography.tinyLabel)
                        .foregroundStyle(message.toneColor)

                    HStack(alignment: .bottom, spacing: .space8) {
                        Text(message.exampleMessage)
                            .font(Theme.Typography.onboardingBody)
                            .foregroundStyle(Theme.Colors.Text.title)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, .space16)
                            .padding(.vertical, .space12)
                            .frame(maxWidth: 290, alignment: .leading)
                            .background(isSelected ? message.toneColor.opacity(0.22) : Theme.Colors.Main.cardSurface)
                            .clipShape(bubbleShape)
                            .overlay(
                                bubbleShape.stroke(
                                    isSelected ? message.toneColor : Theme.Colors.Main.borderSubtle,
                                    lineWidth: isSelected ? 2 : 1
                                )
                            )

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(message.toneColor)
                            .opacity(isSelected ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
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
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(Theme.Typography.onboardingBody)
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

    struct StatsStepView: View {

        private static let chartMaxHeight: CGFloat = 200
        private static let beforeTarget = OnboardingViewModel.StateModel.statsBeforePercent
        private static let afterTarget = OnboardingViewModel.StateModel.statsAfterPercent

        @State private var beforePercent: Double = 0
        @State private var afterPercent: Double = 0

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text(OnboardingViewModel.StateModel.statsHeadline)
                    .font(Theme.Typography.heroTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .onboardingReveal(delay: 0)

                Text(OnboardingViewModel.StateModel.statsBody)
                    .font(Theme.Typography.onboardingBody)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .onboardingReveal(delay: 0.12)

                HStack(alignment: .bottom, spacing: .space32) {
                    OnboardingCountingBar(
                        percent: beforePercent,
                        label: OnboardingViewModel.StateModel.statsBeforeLabel,
                        maxHeight: Self.chartMaxHeight,
                        isHighlighted: false
                    )

                    OnboardingCountingBar(
                        percent: afterPercent,
                        label: OnboardingViewModel.StateModel.statsAfterLabel,
                        maxHeight: Self.chartMaxHeight,
                        isHighlighted: true
                    )
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding(.top, .space16)
                .onboardingReveal(delay: 0.24, from: .bottom)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                    beforePercent = Self.beforeTarget
                }
                withAnimation(.easeOut(duration: 1.1).delay(0.75)) {
                    afterPercent = Self.afterTarget
                }
            }
        }
    }

    struct TactileHoldStepView: View {

        let onComplete: () -> Void

        private let holdDuration: Double = 1.4

        @State private var progress: CGFloat = 0
        @State private var pressLocation: CGPoint?
        @State private var isPressing = false
        @State private var pressToken = UUID()

        var body: some View {
            GeometryReader { geo in
                let center = pressLocation ?? CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let maxDiameter = hypot(geo.size.width, geo.size.height) * 2.2

                ZStack {
                    Circle()
                        .fill(Theme.Colors.Main.accent)
                        .frame(width: maxDiameter * progress, height: maxDiameter * progress)
                        .position(center)
                        .allowsHitTesting(false)

                    VStack(spacing: .space16) {
                        Image(systemName: "hand.point.up.braille.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(progress > 0.5 ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                        Text("Hold to become a Text Master")
                            .font(Theme.Typography.onboardingTitle)
                            .foregroundStyle(progress > 0.5 ? Theme.Colors.Main.background : Theme.Colors.Text.title)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, .space32)
                    .animation(.easeInOut(duration: 0.2), value: progress > 0.5)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
                // A single gesture drives both the finger-tracked circle
                // origin and the hold timing. Completion is tied directly to
                // the growth animation itself finishing (rather than a
                // separate parallel timer racing it), so what you see is
                // exactly what triggers the advance.
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            pressLocation = value.location
                            if !isPressing {
                                beginHold()
                            }
                        }
                        .onEnded { _ in
                            endHold()
                        }
                )
            }
        }

        private func beginHold() {
            isPressing = true
            let token = UUID()
            pressToken = token

            withAnimation(.linear(duration: holdDuration), completionCriteria: .logicallyComplete) {
                progress = 1
            } completion: {
                guard isPressing, pressToken == token else { return }
                onComplete()
            }
        }

        private func endHold() {
            guard isPressing else { return }
            isPressing = false

            if progress < 1 {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    progress = 0
                }
            }
        }
    }
}
