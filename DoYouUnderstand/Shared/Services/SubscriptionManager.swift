//
//  SubscriptionManager.swift
//  DoYouUnderstand
//
//  Thin wrapper around the RevenueCat `Purchases` SDK - fetches the current
//  offering, tracks whether the `pro_access` entitlement is active, and
//  drives the paywall's purchase/restore flows.
//

import Foundation
import RevenueCat

@MainActor
@Observable
final class SubscriptionManager {

    static let shared = SubscriptionManager()

    private static let proEntitlementID = "pro_access"

    private(set) var currentOffering: Offering?
    private(set) var isProUnlocked = false
    private(set) var isLoadingOfferings = false
    private(set) var activeEntitlement: EntitlementInfo?
    var errorMessage: String?

    /// Whether the active entitlement is still within its free-trial period
    /// (as opposed to a paid billing period).
    var isInFreeTrial: Bool {
        activeEntitlement?.periodType == .trial
    }

    /// When the current free trial (or, if not trialing, the current paid
    /// period) ends/renews - `nil` if there's no active entitlement.
    var currentPeriodEndsAt: Date? {
        activeEntitlement?.expirationDate
    }

    /// Whether the subscription is set to auto-renew at `currentPeriodEndsAt`
    /// (false once the user has cancelled but is still in their paid-through period).
    var willRenew: Bool {
        activeEntitlement?.willRenew ?? false
    }

    private init() {}

    /// Call once at launch, after `Purchases.configure(withAPIKey:)`.
    func start() async {
        await fetchOfferings()
        await refreshEntitlementStatus()
    }

    func fetchOfferings() async {
        isLoadingOfferings = true
        defer { isLoadingOfferings = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlementStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            apply(info)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Purchasing -

extension SubscriptionManager {

    enum PurchaseOutcome {
        case success
        case cancelled
        case failure(String)
    }

    func purchase(_ package: Package) async -> PurchaseOutcome {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else { return .cancelled }

            apply(result.customerInfo)
            guard isProUnlocked else {
                return .failure("Purchase completed, but pro access isn't active yet. Please try again in a moment.")
            }
            return .success
        } catch {
            let message = error.localizedDescription
            errorMessage = message
            return .failure(message)
        }
    }

    /// Returns whether an active `pro_access` entitlement was found.
    @discardableResult
    func restorePurchases() async -> Bool {
        do {
            let info = try await Purchases.shared.restorePurchases()
            apply(info)
            return isProUnlocked
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func apply(_ info: CustomerInfo) {
        let entitlement = info.entitlements[Self.proEntitlementID]
        isProUnlocked = entitlement?.isActive == true
        activeEntitlement = entitlement
    }
}
