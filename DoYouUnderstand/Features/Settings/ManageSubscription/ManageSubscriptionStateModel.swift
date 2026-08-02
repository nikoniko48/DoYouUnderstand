//
//  ManageSubscriptionStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

extension ManageSubscriptionViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var isProUnlocked: Bool
        var isInFreeTrial: Bool = false
        var currentPeriodEndsAt: Date?
        var willRenew: Bool = false
        var selectedPlan: OnboardingViewModel.StateModel.PricingPlan
        var isPurchasing: Bool = false
        var isRestoring: Bool = false
        var purchaseErrorMessage: String?
        var restoreResultMessage: String?

        init(
            isProUnlocked: Bool = false,
            selectedPlan: OnboardingViewModel.StateModel.PricingPlan = .annual
        ) {
            self.isProUnlocked = isProUnlocked
            self.selectedPlan = selectedPlan
        }

        /// e.g. "3 days" / "Tomorrow" / "Today" - `nil` when there's no active period end.
        var currentPeriodEndsAtDescription: String? {
            guard let currentPeriodEndsAt else { return nil }
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: currentPeriodEndsAt)).day ?? 0
            switch days {
            case ..<0: return nil
            case 0: return Loc.t("today")
            case 1: return Loc.t("tomorrow")
            default: return String(format: Loc.t("in %d days"), days)
            }
        }

        var statusSubtitle: String {
            guard isProUnlocked else {
                return Loc.t("Upgrade any time to unlock unlimited tone options.")
            }
            if isInFreeTrial, let ending = currentPeriodEndsAtDescription {
                return String(format: Loc.t("Your free trial ends %@."), ending)
            }
            if !willRenew, let ending = currentPeriodEndsAtDescription {
                return String(format: Loc.t("Your access ends %@."), ending)
            }
            if let ending = currentPeriodEndsAtDescription {
                return String(format: Loc.t("Renews %@."), ending)
            }
            return Loc.t("You have full access to every feature.")
        }
    }
}
