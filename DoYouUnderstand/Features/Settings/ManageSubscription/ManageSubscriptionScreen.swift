//
//  ManageSubscriptionScreen.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

struct ManageSubscriptionScreen: View {

    typealias Typography = Theme.Typography
    typealias Colors = Theme.Colors

    @State var viewModel: ManageSubscriptionViewModel

    init(output: @escaping (ManageSubscriptionViewModel.Output) -> Void) {
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

extension ManageSubscriptionScreen {

    struct ContentView: View {

        @Bindable var stateModel: ManageSubscriptionViewModel.StateModel
        let actions: ManageSubscriptionViewModel.Actions

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

                            Text("Subscription")
                                .font(Typography.screenTitle)
                                .foregroundStyle(Colors.Text.title)
                        }

                        Spacer()
                    }
                    .onboardingReveal(delay: 0)

                    // MARK: - Status card
                    HStack(spacing: .space16) {
                        Image(systemName: stateModel.isProUnlocked ? "checkmark.seal.fill" : "seal")
                            .font(.system(size: 26))
                            .foregroundStyle(stateModel.isProUnlocked ? Colors.Main.success.contrastingForeground : Colors.Text.muted)
                            .frame(width: 52, height: 52)
                            .background(stateModel.isProUnlocked ? Colors.Main.success : Colors.Main.background)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Colors.Main.borderSubtle, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: .space4) {
                            HStack(spacing: .space6) {
                                Text(stateModel.isProUnlocked ? "Pro Member" : "Free Plan")
                                    .font(Typography.biggerText)
                                    .foregroundStyle(Colors.Text.title)

                                if stateModel.isInFreeTrial {
                                    Text("FREE TRIAL")
                                        .font(Typography.tinyLabel)
                                        .foregroundStyle(Colors.Main.success.contrastingForeground)
                                        .padding(.horizontal, .space6)
                                        .padding(.vertical, .space2)
                                        .background(Colors.Main.success)
                                        .clipShape(Capsule())
                                }
                            }

                            Text(stateModel.statusSubtitle)
                                .font(Typography.bodyText)
                                .foregroundStyle(Colors.Text.muted)
                        }

                        Spacer(minLength: .space8)
                    }
                    .padding(.space16)
                    .background(Colors.Main.cardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                            .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                    )
                    .onboardingReveal(delay: 0.06)

                    if stateModel.isProUnlocked {
                        Button {
                            actions.onManageOnAppStore?()
                        } label: {
                            HStack {
                                Text("Manage on the App Store")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(Typography.biggerText)
                            .foregroundStyle(Colors.Text.title)
                            .padding(.space16)
                            .background(Colors.Main.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius)
                                    .stroke(Colors.Main.borderSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .onboardingReveal(delay: 0.12)
                    } else {
                        VStack(spacing: .space12) {
                            ForEach(OnboardingViewModel.StateModel.PricingPlan.allCases) { plan in
                                OnboardingScreen.PricingPlanRow(
                                    plan: plan,
                                    isSelected: stateModel.selectedPlan == plan,
                                    isDiscountActive: false
                                ) {
                                    actions.onSelectPlan?(plan)
                                }
                            }
                        }
                        .onboardingReveal(delay: 0.12)

                        Button {
                            actions.onSubscribe?()
                        } label: {
                            HStack(spacing: .space8) {
                                if stateModel.isPurchasing {
                                    ProgressView()
                                        .tint(Colors.Main.accent.contrastingForeground)
                                }
                                Text(stateModel.isPurchasing ? "Processing..." : "Subscribe")
                            }
                            .font(Typography.primaryButton)
                            .foregroundStyle(Colors.Main.accent.contrastingForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .space16)
                            .background(Colors.Main.accent)
                            .clipShape(RoundedRectangle(cornerRadius: StaticData.Layout.cornerRadius))
                        }
                        .disabled(stateModel.isPurchasing)
                        .onboardingReveal(delay: 0.18)
                    }

                    Button {
                        actions.onRestorePurchases?()
                    } label: {
                        HStack(spacing: .space8) {
                            if stateModel.isRestoring {
                                ProgressView()
                                    .tint(Colors.Text.muted)
                            }
                            Text(stateModel.isRestoring ? "Restoring..." : "Restore Purchases")
                        }
                        .font(Typography.bodyText.weight(.bold))
                        .foregroundStyle(Colors.Text.muted)
                        .underline()
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(stateModel.isRestoring)
                    .padding(.top, .space8)
                    .onboardingReveal(delay: 0.24)
                }
                .padding(.horizontal, StaticData.Layout.screenPadding)
                .padding(.top, .space16)
                .padding(.bottom, .space24)
            }
            .onAppear {
                actions.onAppear?()
            }
            .alert(
                "Purchase Failed",
                isPresented: Binding(
                    get: { stateModel.purchaseErrorMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.purchaseErrorMessage = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(stateModel.purchaseErrorMessage ?? "")
            }
            .alert(
                "Restore Purchases",
                isPresented: Binding(
                    get: { stateModel.restoreResultMessage != nil },
                    set: { isPresented in
                        if !isPresented { stateModel.restoreResultMessage = nil }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(stateModel.restoreResultMessage ?? "")
            }
        }
    }
}

#Preview {
    ManageSubscriptionScreen(output: { _ in })
}
