//
//  OnboardingScreen+IntroSteps.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import SwiftUI

extension OnboardingScreen {

    struct GreetingStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "magnifyingglass", text: "Decode what any message really means", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "bolt.fill", text: "Get the perfect reply in seconds", toneColor: Theme.Colors.Tone.sarcastic),
            Feature(icon: "lock.fill", text: "No account, no cloud, 100% private", toneColor: Theme.Colors.Tone.anxious)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space32) {
                Spacer(minLength: .space0)

                VStack(alignment: .leading, spacing: .space16) {
                    Text("STOP GUESSING\nWHAT THEY MEAN.")
                        .font(Theme.Typography.heroTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .onboardingReveal(delay: 0)

                    Text("DoYouUnderstand decodes the subtext behind any text, DM, or email, and hands you the perfect reply.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                        .onboardingReveal(delay: 0.12)
                }

                VStack(alignment: .leading, spacing: .space16) {
                    ForEach(Array(Self.points.enumerated()), id: \.element.id) { index, point in
                        FinisherFeatureRow(icon: point.icon, text: point.text, toneColor: point.toneColor)
                            .onboardingReveal(delay: 0.24 + Double(index) * 0.1)
                    }
                }

                Spacer(minLength: .space0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct NameStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space24) {
                Text("What should we call you?")
                    .font(Theme.Typography.onboardingTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                TextField(
                    "",
                    text: Binding(
                        get: { stateModel.name },
                        set: { actions.onNameChanged?($0) }
                    ),
                    prompt: Text("Your name")
                        .foregroundStyle(Theme.Colors.Text.muted)
                )
                .font(Theme.Typography.onboardingBody.weight(.bold))
                .foregroundStyle(Theme.Colors.Text.title)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(.space16)
                .background(Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                )
                .onboardingReveal(delay: 0.12)
            }
        }
    }

    struct AgeStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            VStack(alignment: .leading, spacing: .space32) {
                Text("How old are you?")
                    .font(Theme.Typography.onboardingTitle)
                    .foregroundStyle(Theme.Colors.Text.title)
                    .onboardingReveal(delay: 0)

                VStack(spacing: .space24) {
                    Text("\(Int(stateModel.age))")
                        .font(Theme.Typography.spaceGrotesk(size: 72, weight: .black))
                        .foregroundStyle(Theme.Colors.Main.accent)
                        .contentTransition(.numericText())
                        .frame(maxWidth: .infinity)

                    Slider(
                        value: Binding(
                            get: { stateModel.age },
                            set: { actions.onAgeChanged?($0) }
                        ),
                        in: OnboardingViewModel.StateModel.ageRange,
                        step: 1
                    )
                    .tint(Theme.Colors.Main.accent)
                }
                .padding(.space24)
                .background(Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                )
                .onboardingReveal(delay: 0.12)
            }
        }
    }

    struct ThemeStepView: View {

        let stateModel: OnboardingViewModel.StateModel
        let actions: OnboardingViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space32) {
                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Choose your theme.")
                            .font(Theme.Typography.onboardingTitle)
                            .foregroundStyle(Theme.Colors.Text.title)
                            .onboardingReveal(delay: 0)

                        VStack(spacing: .space12) {
                            ForEach(Array(AppThemeChoice.allCases.enumerated()), id: \.element.id) { index, theme in
                                ThemePreviewCard(
                                    theme: theme,
                                    isSelected: stateModel.selectedTheme == theme
                                ) {
                                    actions.onSelectTheme?(theme)
                                }
                                .onboardingReveal(delay: 0.1 + Double(index) * 0.08)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Tone color palette")
                            .font(Theme.Typography.screenTitle)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text("Changes with your theme across the whole app. Pick a look now. The actual colors land later.")
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: .space12) {
                            ForEach(TonePaletteChoice.allCases) { palette in
                                TonePaletteRow(
                                    palette: palette,
                                    isSelected: stateModel.selectedTonePalette == palette
                                ) {
                                    actions.onSelectTonePalette?(palette)
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.42)
                }
            }
        }
    }

    struct ThemePreviewCard: View {

        let theme: AppThemeChoice
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: .space8)
                            .fill(theme.previewBackground)
                            .frame(width: 56, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: .space8)
                                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: .space4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground)
                                .frame(width: 28, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground.opacity(0.6))
                                .frame(width: 20, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.previewForeground.opacity(0.35))
                                .frame(width: 24, height: 4)
                        }
                        .padding(.space8)
                    }

                    VStack(alignment: .leading, spacing: .space4) {
                        Text(theme.title)
                            .font(Theme.Typography.onboardingBody.weight(.bold))
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                        Text(theme.subtitle)
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(isSelected ? Theme.Colors.Main.background.opacity(0.7) : Theme.Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: .space8)

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
                            isSelected ? theme.previewBackground : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct TonePaletteRow: View {

        let palette: TonePaletteChoice
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    HStack(spacing: -CGFloat.space8) {
                        ForEach(Array(palette.swatches.enumerated()), id: \.offset) { _, color in
                            Circle()
                                .fill(color)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Circle().stroke(
                                        isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.background,
                                        lineWidth: 2
                                    )
                                )
                        }
                    }

                    Text(palette.title)
                        .font(Theme.Typography.onboardingBody.weight(.bold))
                        .foregroundStyle(isSelected ? Theme.Colors.Main.background : Theme.Colors.Text.title)

                    Spacer(minLength: .space8)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.Colors.Main.background)
                        .opacity(isSelected ? 1 : 0)
                }
                .padding(.space16)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(isSelected ? Theme.Colors.Text.title : Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(
                            isSelected ? Theme.Colors.Main.accent : Theme.Colors.Main.borderSubtle,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    struct IntroStepView: View {

        private static let points: [Feature] = [
            Feature(icon: "text.bubble.fill", text: "Paste any text, DM, or email", toneColor: Theme.Colors.Tone.overEager),
            Feature(icon: "camera.fill", text: "Or snap a screenshot instead", toneColor: Theme.Colors.Tone.passiveAggressive),
            Feature(icon: "sparkles", text: "Get the subtext or a perfect reply, instantly", toneColor: Theme.Colors.Tone.sarcastic)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: .space32) {
                VStack(alignment: .leading, spacing: .space12) {
                    Text("Here's what we do.")
                        .font(Theme.Typography.heroTitle)
                        .foregroundStyle(Theme.Colors.Text.title)
                        .onboardingReveal(delay: 0)

                    Text("No fluff. Just clarity on what people actually mean.")
                        .font(Theme.Typography.onboardingBody)
                        .foregroundStyle(Theme.Colors.Text.muted)
                        .lineSpacing(5)
                        .onboardingReveal(delay: 0.12)
                }

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
}
