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
                .onboardingReveal(delay: 0.52)

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
                .onboardingReveal(delay: 0.62)
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
}
