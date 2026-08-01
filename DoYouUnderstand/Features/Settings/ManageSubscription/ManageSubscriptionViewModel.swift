//
//  ManageSubscriptionViewModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI
import UIKit

@Observable
final class ManageSubscriptionViewModel: StateViewModelProtocol {

    var stateModel: StateModel
    var state: ViewState<StateModel> = .loading

    private(set) var actions: Actions = .init()
    private let output: (Output) -> Void
    private let subscriptionManager: SubscriptionManager

    init(subscriptionManager: SubscriptionManager = .shared, output: @escaping (Output) -> Void) {
        self.subscriptionManager = subscriptionManager
        self.output = output
        self.stateModel = StateModel(isProUnlocked: subscriptionManager.isProUnlocked)
        setActions()
        self.state = .loaded(stateModel)
    }
}

// MARK: - Output -

extension ManageSubscriptionViewModel {

    enum Output {
        case goBack
    }
}

// MARK: - Actions -

extension ManageSubscriptionViewModel {

    struct Actions {
        var onAppear: (() -> Void)?
        var onSelectPlan: ((OnboardingViewModel.StateModel.PricingPlan) -> Void)?
        var onSubscribe: (() -> Void)?
        var onRestorePurchases: (() -> Void)?
        var onManageOnAppStore: (() -> Void)?
        var onTapBack: (() -> Void)?
    }

    private func setActions() {

        actions.onAppear = { [weak self] in
            self?.refreshStatus()
        }

        actions.onSelectPlan = { [weak self] plan in
            self?.stateModel.selectedPlan = plan
        }

        actions.onSubscribe = { [weak self] in
            self?.subscribe()
        }

        actions.onRestorePurchases = { [weak self] in
            self?.restore()
        }

        actions.onManageOnAppStore = {
            guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
            UIApplication.shared.open(url)
        }

        actions.onTapBack = { [weak self] in
            self?.output(.goBack)
        }
    }
}

// MARK: - Functions -

extension ManageSubscriptionViewModel {

    private func refreshStatus() {
        Task { [weak self] in
            guard let self else { return }
            if subscriptionManager.currentOffering == nil {
                await subscriptionManager.fetchOfferings()
            }
            await subscriptionManager.refreshEntitlementStatus()
            applyEntitlementStatus()
        }
    }

    private func applyEntitlementStatus() {
        stateModel.isProUnlocked = subscriptionManager.isProUnlocked
        stateModel.isInFreeTrial = subscriptionManager.isInFreeTrial
        stateModel.currentPeriodEndsAt = subscriptionManager.currentPeriodEndsAt
        stateModel.willRenew = subscriptionManager.willRenew
    }

    private func subscribe() {
        guard !stateModel.isPurchasing else { return }

        guard let offering = subscriptionManager.currentOffering,
              let package = stateModel.selectedPlan.package(in: offering) else {
            stateModel.purchaseErrorMessage = "We couldn't load the subscription plans. Please check your connection and try again."
            return
        }

        stateModel.isPurchasing = true
        Task { [weak self] in
            guard let self else { return }
            let outcome = await subscriptionManager.purchase(package)
            stateModel.isPurchasing = false

            switch outcome {
            case .success:
                applyEntitlementStatus()
            case .cancelled:
                break
            case .failure(let message):
                stateModel.purchaseErrorMessage = message
            }
        }
    }

    private func restore() {
        guard !stateModel.isRestoring else { return }

        stateModel.isRestoring = true
        Task { [weak self] in
            guard let self else { return }
            let restored = await subscriptionManager.restorePurchases()
            stateModel.isRestoring = false
            applyEntitlementStatus()
            stateModel.restoreResultMessage = restored
                ? "Your Pro access has been restored!"
                : "No active subscription was found to restore."
        }
    }
}
