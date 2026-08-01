//
//  OnboardingScreen+ClosingSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

extension OnboardingScreen {

    struct PrivacyStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "lock.fill", text: "Messages are processed ephemerally and securely", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "internaldrive.fill", text: "History is saved strictly to your device's disk", toneColor: Theme.Colors.Tone.anxious),
            Feature(icon: "xmark.icloud.fill", text: "Zero cloud databases, no accounts required", toneColor: Theme.Colors.Tone.condescending)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                VStack(alignment: .leading, spacing: .space12) {
                    Text("Your Data is Safe With Us.")
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Everything runs on a local-first architecture. No accounts, no sign-up, no server-side profile of you.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }
                .onboardingReveal(delay: 0.1)

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Array(Self.points.enumerated()), id: \.element.id) { index, point in
                        FinisherFeatureRow(icon: point.icon, text: point.text, toneColor: point.toneColor)
                            .onboardingReveal(delay: 0.24 + Double(index) * 0.1)
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
            // The features list + trial callout + ticker + pricing + savings
            // line no longer reliably fit in the space between the header
            // and the "START FREE TRIAL" footer on smaller screens - this
            // step now scrolls like the other content-heavy steps do.
            ScrollView {
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
                    .onboardingReveal(delay: 0)

                VStack(alignment: .leading, spacing: .space12) {
                    Text("The days of second-guessing are over.")
                        .font(Theme.Typography.onboardingTitle)
                        .foregroundStyle(Theme.Colors.Text.title)

                    Text("Get the subtext, craft the perfect response, and hit send with zero regrets.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                }
                .onboardingReveal(delay: 0.1)

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Array(Self.features.enumerated()), id: \.element.id) { index, feature in
                        FinisherFeatureRow(icon: feature.icon, text: feature.text, toneColor: feature.toneColor)
                            .onboardingReveal(delay: 0.22 + Double(index) * 0.1)
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
                        Text("FREE TRIAL")
                            .font(Theme.Typography.badgeLabel)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text("Try it risk-free. Cancel before it ends and you won't be charged.")
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
                .onboardingReveal(delay: 0.52)

                // MARK: - Feature Ticker
                PaywallFeatureTicker()
                    .onboardingReveal(delay: 0.58)

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

                    if isDiscountActive {
                        HStack(spacing: .space6) {
                            Image(systemName: "tag.fill")
                            Text("You'll save \(stateModel.selectedPlan.discountSavingsLabel) if you subscribe within the next 3 hours.")
                        }
                        .font(Theme.Typography.smallBody.weight(.bold))
                        .foregroundStyle(Theme.Colors.Main.success)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .onboardingReveal(delay: 0.62)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                                .foregroundStyle(Theme.Colors.Text.title)

                            if let badge = plan.badge {
                                Text(badge)
                                    .font(Theme.Typography.tinyLabel)
                                    .foregroundStyle(Theme.Colors.Main.accent)
                                    .padding(.horizontal, .space6)
                                    .padding(.vertical, .space2)
                                    .overlay(
                                        Capsule().stroke(Theme.Colors.Main.accent, lineWidth: 1)
                                    )
                            }
                        }

                        if isDiscountActive {
                            HStack(spacing: .space6) {
                                Text(plan.standardPrice)
                                    .strikethrough()
                                    .foregroundStyle(Theme.Colors.Text.muted)

                                Text("\(plan.discountedPrice)\(plan.period)")
                                    .foregroundStyle(Theme.Colors.Text.title)
                            }
                            .font(Theme.Typography.smallBody)
                        } else {
                            Text("\(plan.standardPrice)\(plan.period)")
                                .font(Theme.Typography.smallBody)
                                .foregroundStyle(Theme.Colors.Text.title)
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle)
                }
                .padding(.space16)
                // Selected state used to fully invert to solid black/white,
                // which read as jarring next to the rest of the app's flat
                // dark cards - a soft accent tint + border communicates
                // selection just as clearly without the harsh flip, and
                // keeps all text at normal (never opacity-reduced) contrast.
                .background(isSelected ? Theme.Colors.Main.accent.opacity(0.12) : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle, lineWidth: isSelected ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    /// A row of real feature badges above the pricing section that slowly
    /// auto-advances through itself, while still being manually swipeable.
    /// An earlier version auto-scrolled via a measured `.offset()` inside a
    /// hidden-view/`GeometryReader` trick, but that combination corrupted
    /// the reported frame of later sibling views (broke hit testing, and
    /// would have been equally fragile for real layout). Driving a real
    /// `ScrollViewReader.scrollTo(_:)` on a timer avoids that entirely -
    /// it's a plain `ScrollView`, just nudged forward periodically.
    struct PaywallFeatureTicker: View {

        private static let badges: [String] = [
            "🔒 100% Private",
            "⚡ Instant AI Analysis",
            "🎯 15 Reply Tones",
            "🧠 Gemini-Powered",
            "✍️ Edit Any Reply"
        ]

        @State private var currentIndex = 0
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .space12) {
                        ForEach(Array(Self.badges.enumerated()), id: \.offset) { index, badge in
                            Text(badge)
                                .font(Theme.Typography.tinyLabel)
                                .foregroundStyle(Theme.Colors.Text.muted)
                                .padding(.horizontal, .space12)
                                .padding(.vertical, .space6)
                                .background(Theme.Colors.Main.cardSurface)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                                )
                                .fixedSize()
                                .id(index)
                        }
                    }
                }
                .task {
                    guard !reduceMotion else { return }
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 2_200_000_000)
                        guard !Task.isCancelled else { return }
                        currentIndex = (currentIndex + 1) % Self.badges.count
                        withAnimation(.easeInOut(duration: 0.7)) {
                            proxy.scrollTo(currentIndex, anchor: .leading)
                        }
                    }
                }
            }
        }
    }
}
