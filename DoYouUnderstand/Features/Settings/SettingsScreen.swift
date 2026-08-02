//
//  SettingsScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

struct SettingsScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: SettingsViewModel

    init(output: @escaping (SettingsViewModel.Output) -> Void) {
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.actions.onTapBack?()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .accessibilityIdentifier("backButton")
            }
            ToolbarItem(placement: .principal) {
                VStack(alignment: .leading, spacing: .space2) {
                    Text("SETTINGS")
                        .font(Typography.badgeLabel)
                        .foregroundStyle(Colors.Text.muted)

                    Text("Preferences")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension SettingsScreen {

    struct ContentView: View {

        let stateModel: SettingsViewModel.StateModel
        let actions: SettingsViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space24) {

                    // MARK: - Profile card
                    Button {
                        actions.onTapProfile?()
                    } label: {
                        HStack(spacing: .space16) {
                            Text(stateModel.initials)
                                .font(Typography.spaceGrotesk(size: 22, weight: .black))
                                .foregroundStyle(Colors.Main.accent.contrastingForeground)
                                .frame(width: 52, height: 52)
                                .background(Colors.Main.accent)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: .space2) {
                                Text(stateModel.hasProfile ? stateModel.name : Loc.t("Add your name"))
                                    .font(Typography.biggerText)
                                    .foregroundStyle(Colors.Text.title)

                                Text(stateModel.profileSubtitle)
                                    .font(Typography.bodyText)
                                    .foregroundStyle(Colors.Text.muted)
                            }

                            Spacer(minLength: .space8)

                            Image(systemName: "chevron.right")
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.muted)
                        }
                        .padding(.space16)
                        .background(Colors.Main.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settingsProfileRow")
                    .onboardingReveal(delay: 0.06)

                    // MARK: - Settings rows
                    VStack(alignment: .leading, spacing: .space12) {
                        Text("PREFERENCES")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)

                        VStack(spacing: .space12) {
                            SettingsRow(
                                icon: "paintbrush.fill",
                                iconTint: Colors.Tone.playful,
                                title: "Appearance",
                                subtitle: "Theme and tone colors"
                            ) {
                                actions.onTapTheme?()
                            }

                            SettingsRow(
                                icon: "globe",
                                iconTint: Colors.Main.secondaryAccent,
                                title: "Language",
                                subtitle: stateModel.selectedLanguage.title
                            ) {
                                actions.onTapLanguage?()
                            }

                            SettingsRow(
                                icon: "creditcard.fill",
                                iconTint: Colors.Tone.overEager,
                                title: "Subscription",
                                subtitle: "Manage your plan"
                            ) {
                                actions.onTapManageSubscription?()
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.12)

                    VStack(alignment: .leading, spacing: .space12) {
                        Text("ABOUT")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)

                        VStack(spacing: .space12) {
                            SettingsRow(
                                icon: "lock.shield.fill",
                                iconTint: Colors.Main.success,
                                title: "Privacy Policy",
                                subtitle: "How your data is handled"
                            ) {
                                actions.onTapPrivacyPolicy?()
                            }

                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                iconTint: Colors.Tone.friendly,
                                title: "FAQ",
                                subtitle: "Common questions"
                            ) {
                                actions.onTapFAQ?()
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.18)
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
            .onAppear {
                actions.onAppear?()
            }
        }
    }
}

// MARK: - Subcomponents -

extension SettingsScreen {

    struct SettingsRow: View {

        let icon: String
        let iconTint: Color
        let title: String
        let subtitle: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    Image(systemName: icon)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(iconTint.contrastingForeground)
                        .frame(width: 36, height: 36)
                        .background(iconTint)
                        .clipShape(RoundedRectangle(cornerRadius: .space8))

                    VStack(alignment: .leading, spacing: .space2) {
                        Text(LocalizedStringKey(title))
                            .font(Theme.Typography.biggerText)
                            .foregroundStyle(Theme.Colors.Text.title)

                        Text(LocalizedStringKey(subtitle))
                            .font(Theme.Typography.bodyText)
                            .foregroundStyle(Theme.Colors.Text.muted)
                    }

                    Spacer(minLength: .space8)

                    Image(systemName: "chevron.right")
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Text.muted)
                }
                .padding(.space16)
                .background(Theme.Colors.Main.cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                        .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsScreen(output: { _ in })
}
