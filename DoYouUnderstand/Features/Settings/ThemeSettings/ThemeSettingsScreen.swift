//
//  ThemeSettingsScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

/// Settings' version of onboarding's theme step - same cards/rows (reused
/// directly, `OnboardingScreen.ThemePreviewCard`/`TonePaletteRow` take plain
/// values and have no onboarding-specific coupling), but selections apply
/// immediately with no "Continue" step, and it has its own back-button header
/// matching the rest of Settings instead of the funnel's progress bar.
struct ThemeSettingsScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: ThemeSettingsViewModel

    init(output: @escaping (ThemeSettingsViewModel.Output) -> Void) {
        self.viewModel = .init(output: output)
    }

    var body: some View {
        StateScreen(state: viewModel.state) { stateModel in
            ContentView(
                stateModel: stateModel,
                actions: viewModel.actions
            )
        }
        .navigationBarBackButtonHidden()
    }
}

extension ThemeSettingsScreen {

    struct ContentView: View {

        let stateModel: ThemeSettingsViewModel.StateModel
        let actions: ThemeSettingsViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space32) {

                    // MARK: - Header
                    HStack(spacing: .space16) {
                        Button {
                            actions.onTapBack?()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(Typography.bodyText)
                                .scaleEffect(1.2)
                                .foregroundStyle(Colors.Text.highlight)
                                .frame(width: StaticData.Layout.backButtonSize.width, height: StaticData.Layout.backButtonSize.height)
                                .background(Colors.Main.cardSurface)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Colors.Main.borderSubtle, lineWidth: 1)
                                )
                        }
                        .accessibilityIdentifier("backButton")

                        VStack(alignment: .leading, spacing: .space2) {
                            Text("SETTINGS")
                                .font(Typography.badgeLabel)
                                .foregroundStyle(Colors.Text.muted)

                            Text("Appearance")
                                .font(Typography.screenTitle)
                                .foregroundStyle(Colors.Text.title)
                        }

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("App theme")
                            .font(Typography.hugeTitle)
                            .foregroundStyle(Colors.Text.title)
                            .onboardingReveal(delay: 0)

                        VStack(spacing: .space12) {
                            ForEach(Array(AppThemeChoice.allCases.enumerated()), id: \.element.id) { index, theme in
                                OnboardingScreen.ThemePreviewCard(
                                    theme: theme,
                                    isSelected: stateModel.selectedTheme == theme
                                ) {
                                    actions.onSelectTheme?(theme)
                                }
                                .onboardingReveal(delay: 0.06 + Double(index) * 0.06)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Tone color palette")
                            .font(Typography.hugeTitle)
                            .foregroundStyle(Colors.Text.title)

                        Text("Colors the 15 message tones - independent of your app theme.")
                            .font(Typography.bodyText)
                            .foregroundStyle(Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: .space12) {
                            ForEach(TonePaletteChoice.allCases) { palette in
                                OnboardingScreen.TonePaletteRow(
                                    palette: palette,
                                    isSelected: stateModel.selectedTonePalette == palette
                                ) {
                                    actions.onSelectTonePalette?(palette)
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.3)
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
        }
    }
}

#Preview {
    ThemeSettingsScreen(output: { _ in })
}
