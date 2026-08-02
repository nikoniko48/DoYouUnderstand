//
//  OnboardingScreen+QuizSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI
import UIKit

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

                BouncingDotsLoader(color: Theme.Colors.Main.accent, dotSize: 12)

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

        // How long a *continuous, unbroken* hold takes to fill the screen,
        // and how long it takes to drain back to nothing once released.
        // Draining faster than filling makes letting go feel responsive.
        private let fillDuration: Double = 1.4
        private let drainDuration: Double = 0.5
        private let tickInterval: Double = 1.0 / 60.0

        @State private var progress: CGFloat = 0
        @State private var pressLocation: CGPoint?
        @State private var isPressing = false
        @State private var hasCompleted = false
        @State private var driverTask: Task<Void, Never>?
        @State private var haptics = TactileHoldHapticEngine()

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
                // origin and the press/release state. The fill itself is
                // driven by a real per-frame loop tied to `isPressing`
                // rather than a fire-and-forget animation, so the circle is
                // always an honest reflection of how long you've actually
                // been holding - hold, and it grows; let go, and it shrinks.
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
            .onDisappear {
                driverTask?.cancel()
                driverTask = nil
                haptics.cancel()
            }
        }

        private func beginHold() {
            guard !hasCompleted else { return }
            isPressing = true
            haptics.touchDown(duration: fillDuration)
            startDriverLoopIfNeeded()
        }

        private func endHold() {
            isPressing = false
            if !hasCompleted {
                haptics.cancel()
            }
        }

        private func startDriverLoopIfNeeded() {
            guard driverTask == nil else { return }

            let fillPerTick = CGFloat(tickInterval / fillDuration)
            let drainPerTick = CGFloat(tickInterval / drainDuration)

            driverTask = Task { @MainActor in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(tickInterval * 1_000_000_000))
                    guard !Task.isCancelled, !hasCompleted else { break }

                    if isPressing {
                        progress = min(1, progress + fillPerTick)
                        haptics.updateProgress(Double(progress))
                        if progress >= 1 {
                            await confirmCompletion()
                            break
                        }
                    } else {
                        progress = max(0, progress - drainPerTick)
                        if progress <= 0 {
                            break
                        }
                    }
                }
                driverTask = nil
            }
        }

        @MainActor
        private func confirmCompletion() async {
            hasCompleted = true
            haptics.complete()
            onComplete()
        }
    }
}
