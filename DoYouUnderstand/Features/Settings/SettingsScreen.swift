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
    }
}

extension SettingsScreen {

    struct ContentView: View {

        let stateModel: SettingsViewModel.StateModel
        let actions: SettingsViewModel.Actions

        var body: some View {
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
                        Text("SETTINGS")
                            .font(Typography.badgeLabel)
                            .foregroundStyle(Colors.Text.muted)

                        Text("Preferences")
                            .font(Typography.screenTitle)
                            .foregroundStyle(Colors.Text.title)
                    }

                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, StaticData.Layout.screenPadding)
            .padding(.top, .space16)
        }
    }
}

#Preview {
    SettingsScreen(output: { _ in })
}
