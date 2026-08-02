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

                    Text("Language")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension LanguageSettingsScreen {

    struct ContentView: View {

        let stateModel: LanguageSettingsViewModel.StateModel
        let actions: LanguageSettingsViewModel.Actions

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space24) {

                    HStack(alignment: .top, spacing: .space12) {
                        Image(systemName: "globe")
                            .font(Typography.bodyText)
                            .foregroundStyle(Colors.Main.secondaryAccent)

                        Text("English, Polish, and Spanish are fully translated. Other languages will keep showing English until they're added.")
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

                    VStack(alignment: .leading, spacing: .space16) {
                        VStack(alignment: .leading, spacing: .space4) {
                            Text("Default Reply Language")
                                .font(Typography.screenTitle)
                                .foregroundStyle(Colors.Text.title)

                            Text("Applies to newly generated replies. \"Auto-detect\" matches the language of the message you paste in.")
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(spacing: .space12) {
                            ForEach(Array(ReplyLanguage.allCases.enumerated()), id: \.element.id) { index, language in
                                ReplyLanguageRow(
                                    language: language,
                                    isSelected: stateModel.selectedReplyLanguage == language
                                ) {
                                    actions.onSelectReplyLanguage?(language)
                                }
                                .onboardingReveal(delay: 0.4 + Double(index) * 0.05)
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.36)
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

    struct ReplyLanguageRow: View {

        let language: ReplyLanguage
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: .space16) {
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
                .frame(maxWidth: .infinity, minHeight: 56)
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
