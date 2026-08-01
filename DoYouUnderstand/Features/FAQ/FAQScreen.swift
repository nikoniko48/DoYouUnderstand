//
//  FAQScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import SwiftUI

struct FAQScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: FAQViewModel

    init(output: @escaping (FAQViewModel.Output) -> Void) {
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
    }
}

extension FAQScreen {

    struct ContentView: View {

        let stateModel: FAQViewModel.StateModel
        let actions: FAQViewModel.Actions

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

                        VStack(alignment: .leading, spacing: .space2) {
                            Text("SUPPORT")
                                .font(Typography.badgeLabel)
                                .foregroundStyle(Colors.Text.muted)

                            Text("Frequently Asked Questions")
                                .font(Typography.screenTitle)
                                .foregroundStyle(Colors.Text.title)
                        }

                        Spacer()
                    }
                    .onboardingReveal(delay: 0)

                    VStack(spacing: .space12) {
                        ForEach(Array(stateModel.questions.enumerated()), id: \.element.id) { index, item in
                            FAQRow(item: item)
                                .onboardingReveal(delay: 0.06 + Double(index) * 0.04)
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

extension FAQScreen {

    struct FAQRow: View {

        let item: FAQItem
        @State private var isExpanded: Bool = false

        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                Text(item.answer)
                    .font(Theme.Typography.bodyText)
                    .foregroundStyle(Theme.Colors.Text.muted)
                    .lineSpacing(4)
                    .padding(.top, .space8)
                    .padding(.leading, 36 + .space12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                HStack(spacing: .space12) {
                    Image(systemName: item.icon)
                        .font(Theme.Typography.bodyText)
                        .foregroundStyle(Theme.Colors.Main.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.Main.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: .space8))

                    Text(item.question)
                        .font(Theme.Typography.bodyText.weight(.bold))
                        .foregroundStyle(Theme.Colors.Text.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .tint(Theme.Colors.Text.muted)
            .padding(.space16)
            .background(Theme.Colors.Main.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                    .stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    FAQScreen(output: { _ in })
}
