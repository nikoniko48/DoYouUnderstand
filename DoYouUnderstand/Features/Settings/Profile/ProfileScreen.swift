//
//  ProfileScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

struct ProfileScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: ProfileViewModel

    init(output: @escaping (ProfileViewModel.Output) -> Void) {
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

                    Text("Your Profile")
                        .font(Typography.screenTitle)
                        .foregroundStyle(Colors.Text.title)
                }
            }
        }
    }
}

extension ProfileScreen {

    struct ContentView: View {

        let stateModel: ProfileViewModel.StateModel
        let actions: ProfileViewModel.Actions

        @FocusState private var isNameFieldFocused: Bool

        private static let genderRows: [[OnboardingViewModel.StateModel.GenderChoice]] = {
            stride(from: 0, to: OnboardingViewModel.StateModel.GenderChoice.allCases.count, by: 2).map {
                Array(OnboardingViewModel.StateModel.GenderChoice.allCases[$0..<min($0 + 2, OnboardingViewModel.StateModel.GenderChoice.allCases.count)])
            }
        }()

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: .space24) {

                    // MARK: - Saved confirmation
                    if stateModel.showsSavedConfirmation {
                        HStack(spacing: .space16) {
                            Spacer(minLength: .space0)

                            HStack(spacing: .space6) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Saved")
                            }
                            .font(Typography.bodyText.weight(.bold))
                            .foregroundStyle(Colors.Main.success.contrastingForeground)
                            .padding(.horizontal, .space12)
                            .padding(.vertical, .space8)
                            .background(Colors.Main.success)
                            .clipShape(Capsule())
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }

                    // MARK: - Avatar
                    VStack(spacing: .space12) {
                        Text(stateModel.initials)
                            .font(Theme.Typography.spaceGrotesk(size: 40, weight: .black))
                            .foregroundStyle(Colors.Main.accent.contrastingForeground)
                            .frame(width: 96, height: 96)
                            .background(Colors.Main.accent)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Colors.Main.borderSubtle, lineWidth: 1)
                            )
                            .contentTransition(.interpolate)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: stateModel.initials)

                        if stateModel.isNameValid {
                            Text(stateModel.name)
                                .font(Typography.hugeTitle)
                                .foregroundStyle(Colors.Text.title)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onboardingReveal(delay: 0.05)

                    VStack(alignment: .leading, spacing: .space8) {
                        Text("Name")
                            .font(Typography.biggerText)
                            .foregroundStyle(Colors.Text.title)

                        TextField(
                            "",
                            text: Binding(
                                get: { stateModel.name },
                                set: { actions.onNameChanged?($0) }
                            ),
                            prompt: Text("Your name").foregroundStyle(Colors.Text.muted)
                        )
                        .font(Typography.onboardingBody.weight(.bold))
                        .foregroundStyle(Colors.Text.title)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($isNameFieldFocused)
                        .padding(.space16)
                        .background(Colors.Main.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                        )
                    }
                    .onboardingReveal(delay: 0.12)

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Age")
                            .font(Typography.biggerText)
                            .foregroundStyle(Colors.Text.title)

                        HStack(spacing: .space24) {
                            AgeStepperButton(
                                icon: "minus",
                                isEnabled: stateModel.age > ProfileViewModel.StateModel.ageRange.lowerBound
                            ) {
                                actions.onAgeDecrement?()
                            }
                            .accessibilityLabel("Decrease age")

                            Text("\(Int(stateModel.age))")
                                .font(Typography.spaceGrotesk(size: 36, weight: .black))
                                .foregroundStyle(Colors.Main.accent)
                                .contentTransition(.numericText())
                                // Space Grotesk's line height at this size/weight
                                // is noticeably taller than its cap-height, which
                                // left visible empty space above the digits when
                                // this Text was left to size itself - clamping to
                                // the stepper buttons' own height keeps the glyph
                                // centered against them instead.
                                .frame(minWidth: 64, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)

                            AgeStepperButton(
                                icon: "plus",
                                isEnabled: stateModel.age < ProfileViewModel.StateModel.ageRange.upperBound
                            ) {
                                actions.onAgeIncrement?()
                            }
                            .accessibilityLabel("Increase age")
                        }
                    }
                    .padding(.space16)
                    .background(Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0.19)

                    VStack(alignment: .leading, spacing: .space16) {
                        Text("Gender")
                            .font(Typography.biggerText)
                            .foregroundStyle(Colors.Text.title)

                        VStack(spacing: .space12) {
                            ForEach(Self.genderRows, id: \.self) { row in
                                HStack(spacing: .space12) {
                                    ForEach(row) { gender in
                                        OnboardingScreen.GenderOptionChip(
                                            title: gender.displayName,
                                            isSelected: stateModel.selectedGender == gender
                                        ) {
                                            actions.onSelectGender?(gender)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onboardingReveal(delay: 0.26)
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
            // Same fix as onboarding's Age step - the vertical ScrollView's
            // default edge clipping sliced the selected gender chip's
            // border on the sides.
            .scrollClipDisabled()
            .safeAreaInset(edge: .bottom) {
                if stateModel.hasUnsavedChanges {
                    HStack(spacing: .space12) {
                        Button {
                            isNameFieldFocused = false
                            actions.onCancel?()
                        } label: {
                            Text("Cancel")
                                .font(Typography.primaryButton)
                                .foregroundStyle(Colors.Text.title)
                        }
                        .buttonStyle(
                            LiquidGlassCTAButtonStyle(
                                tint: Colors.Main.cardSurface,
                                verticalPadding: .space16
                            )
                        )

                        Button {
                            isNameFieldFocused = false
                            actions.onSave?()
                        } label: {
                            Text("Save Changes")
                                .font(Typography.primaryButton)
                                .foregroundStyle(Colors.Main.accent.contrastingForeground)
                        }
                        .buttonStyle(
                            LiquidGlassCTAButtonStyle(
                                tint: Colors.Main.accent,
                                verticalPadding: .space16
                            )
                        )
                        .disabled(!stateModel.isNameValid)
                        .opacity(stateModel.isNameValid ? 1 : 0.5)
                    }
                    .padding(.horizontal, StaticData.Layout.screenPadding)
                    .padding(.top, .space8)
                    .padding(.bottom, .space8)
                    .background(Colors.Main.background)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stateModel.hasUnsavedChanges)
        }
    }
}

// MARK: - Subcomponents -

extension ProfileScreen {

    struct AgeStepperButton: View {

        let icon: String
        let isEnabled: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(Theme.Typography.biggerText.weight(.bold))
                    .foregroundStyle(Theme.Colors.Text.title)
                    .frame(width: 44, height: 44)
                    .background(Theme.Colors.Main.background)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Theme.Colors.Main.borderSubtle, lineWidth: 1)
                    )
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.4)
        }
    }
}

#Preview {
    ProfileScreen(output: { _ in })
}
