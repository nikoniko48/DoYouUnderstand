//
//  OnboardingScreen+Components.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

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
                            .font(Theme.Typography.onboardingBody.weight(.bold))
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(Theme.Typography.bodyText)
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
                .frame(maxWidth: .infinity, minHeight: 84)
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

    struct Feature: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let toneColor: Color
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
                    .font(Theme.Typography.onboardingBody.weight(.semibold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Transitions -

extension AnyTransition {

    static var onboardingStep: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
