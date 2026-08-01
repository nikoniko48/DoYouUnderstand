//
//  LanguageSettingsScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

struct LanguageSettingsScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: LanguageSettingsViewModel

    init(output: @escaping (LanguageSettingsViewModel.Output) -> Void) {
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

extension LanguageSettingsScreen {

    struct ContentView: View {

        let stateModel: LanguageSettingsViewModel.StateModel
        let actions: LanguageSettingsViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space24) {

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

                            Text("Language")
                                .font(Typography.screenTitle)
                                .foregroundStyle(Colors.Text.title)
                        }

                        Spacer()
                    }
                    .onboardingReveal(delay: 0)

                    HStack(alignment: .top, spacing: .space12) {
                        Image(systemName: "hourglass")
                            .font(Typography.bodyText)
                            .foregroundStyle(Colors.Main.secondaryAccent)

                        Text("Translations are coming soon. Your pick is saved, but the app will keep showing English until this ships.")
                            .font(Typography.bodyText)
                            .foregroundStyle(Colors.Text.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.space16)
                    .background(Colors.Main.secondaryAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Colors.Main.secondaryAccent.opacity(0.3), lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0.08)

                    VStack(spacing: .space12) {
                        ForEach(Array(LanguageChoice.allCases.enumerated()), id: \.element.id) { index, language in
                            LanguageRow(
                                language: language,
                                isSelected: stateModel.selectedLanguage == language
                            ) {
                                actions.onSelectLanguage?(language)
                            }
                            .onboardingReveal(delay: 0.16 + Double(index) * 0.05)
                        }
                    }
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
        }
    }
}

// MARK: - Subcomponents -

extension LanguageSettingsScreen {

    struct LanguageRow: View {

        let language: LanguageChoice
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
                    Text(language.flag)
                        .font(.system(size: 26))

                    Text(language.title)
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
}

#Preview {
    LanguageSettingsScreen(output: { _ in })
}
