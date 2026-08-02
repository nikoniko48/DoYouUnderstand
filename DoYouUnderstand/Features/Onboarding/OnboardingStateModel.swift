//
//  OnboardingStateModel.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 28/07/2026.
//

import SwiftUI

extension OnboardingViewModel {

    @Observable
    final class StateModel: StateModelProtocol {
        var currentStep: Int
        var name: String
        var age: Double
        var selectedGender: GenderChoice?
        var selectedTheme: AppThemeChoice?
        var selectedTonePalette: TonePaletteChoice?
        var selectedTriggerMessage: TriggerMessage?
        var processingMessageIndex: Int
        var selectedPlan: PricingPlan
        var isPurchasing = false
        var purchaseErrorMessage: String?
        /// Drives the greeting screen's one-time "decryption" cinematic -
        /// the shared footer hides its "Get Started" button while this is
        /// true so the user can't advance mid-animation.
        var isGreetingIntroPlaying = true

        let totalSteps: Int = Step.allCases.count
        let progressStepCount: Int = Step.allCases.count - 1

        init(
            currentStep: Int = 0,
            name: String = "",
            age: Double = 25,
            selectedGender: GenderChoice? = nil,
            selectedTheme: AppThemeChoice? = ThemeManager.shared.appTheme,
            selectedTonePalette: TonePaletteChoice? = ThemeManager.shared.tonePalette,
            selectedTriggerMessage: TriggerMessage? = nil,
            processingMessageIndex: Int = 0,
            selectedPlan: PricingPlan = .annual
        ) {
            self.currentStep = currentStep
            self.name = name
            self.age = age
            self.selectedGender = selectedGender
            self.selectedTheme = selectedTheme
            self.selectedTonePalette = selectedTonePalette
            self.selectedTriggerMessage = selectedTriggerMessage
            self.processingMessageIndex = processingMessageIndex
            self.selectedPlan = selectedPlan
        }

        static let ageRange: ClosedRange<Double> = 10...100

        var step: Step {
            Step(rawValue: currentStep) ?? .greeting
        }

        var isProcessingStep: Bool {
            step == .processing
        }

        var isFinisherStep: Bool {
            step == .finisher
        }

        /// The progress bar + "STEP X OF Y" label only make sense once the
        /// funnel actually starts - the greeting screen hides it.
        var showsProgressHeader: Bool {
            step != .greeting
        }

        var displayStepNumber: Int {
            currentStep
        }

        var isNameValid: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var isContinueEnabled: Bool {
            switch step {
            case .greeting, .intro, .stats, .processing, .privacy, .toneDemo, .finisher:
                return true
            case .name:
                return isNameValid
            case .age:
                return selectedGender != nil
            case .theme:
                return selectedTheme != nil
            case .triggerMessage, .tactileHold:
                return true
            }
        }

        var processingMessage: String {
            Self.processingMessages[processingMessageIndex % Self.processingMessages.count]
        }

        // Computed, not `static let` - a `let` would cache whichever
        // language was active the first time this was read, and never
        // re-resolve after a live language switch in Settings.
        static var processingMessages: [String] {
            [
                Loc.t("Analyzing triggers..."),
                Loc.t("Preparing defense strategies..."),
                Loc.t("Cross-referencing tone patterns..."),
                Loc.t("Decoding emotional undertones...")
            ]
        }

        // 6 ticks x 0.5s = exactly 3.0 seconds.
        static let processingTickCount = 6

        static var statsHeadline: String { Loc.t("We've got great news for you.") }
        // The 31% figure is real (Viber's "21st Century Messaging Etiquette"
        // survey, 2,400 US/UK respondents via Pollfish, 2018). The 92% is our
        // own product claim about app users, not part of that survey.
        static var statsBody: String {
            Loc.t("31% of people say texting is a daily source of stress. Users like you see a 92% reduction in that anxiety within the first two weeks.")
        }
        static let statsBeforePercent: Double = 31
        static let statsAfterPercent: Double = 92
        static var statsBeforeLabel: String { Loc.t("People Today") }
        static var statsAfterLabel: String { Loc.t("With Us") }
    }
}

// MARK: - Steps & Options -

extension OnboardingViewModel.StateModel {

    enum Step: Int, CaseIterable {
        case greeting = 0
        case name = 1
        case age = 2
        case theme = 3
        case intro = 4
        case triggerMessage = 5
        case processing = 6
        case stats = 7
        case tactileHold = 8
        case privacy = 9
        case toneDemo = 10
        case finisher = 11
    }

    enum PricingPlan: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case annual = "Annual"

        var id: String { rawValue }

        /// Localized display name - `rawValue` itself stays the fixed
        /// English plan name (used as its `Identifiable` id and passed
        /// around internally), so UI that shows the plan's name to the
        /// user should read this instead of `rawValue`.
        var displayName: String { Loc.t(rawValue) }

        var period: String {
            switch self {
            case .monthly: return Loc.t("/ month")
            case .annual: return Loc.t("/ year")
            }
        }

        var standardPrice: String {
            switch self {
            case .monthly: return "$10"
            case .annual: return "$100"
            }
        }

        var discountedPrice: String {
            switch self {
            case .monthly: return "$8"
            case .annual: return "$79"
            }
        }

        var badge: String? {
            self == .annual ? Loc.t("BEST VALUE") : nil
        }

        func price(discountActive: Bool) -> String {
            discountActive ? discountedPrice : standardPrice
        }

        /// Flat dollar difference between `standardPrice` and `discountedPrice`,
        /// shown in the "you'll save X" nudge under the pricing rows.
        var discountSavingsLabel: String {
            switch self {
            case .monthly: return "$2"
            case .annual: return "$21"
            }
        }
    }

    enum GenderChoice: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        case nonConforming = "Non-Conforming"
        case preferNotToSay = "Prefer Not to Say"

        var id: String { rawValue }

        /// Localized display name - `rawValue` itself stays the fixed
        /// English value (it's persisted via `UserProfileStore`), so UI
        /// that shows this to the user should read this instead.
        var displayName: String { Loc.t(rawValue) }
    }

    enum TriggerMessage: CaseIterable, Identifiable {
        case friendAnnoying
        case bossPassiveAggressive
        case intrusiveParent
        case strongPartner

        var id: Self { self }

        /// Who the example message below is "from" - shown as a small label
        /// above the chat bubble.
        var senderLabel: String {
            switch self {
            case .friendAnnoying: return Loc.t("FROM A FRIEND")
            case .bossPassiveAggressive: return Loc.t("FROM YOUR BOSS")
            case .intrusiveParent: return Loc.t("FROM A PARENT")
            case .strongPartner: return Loc.t("FROM A PARTNER")
            }
        }

        /// The actual example message shown inside the chat bubble.
        var exampleMessage: String {
            switch self {
            case .friendAnnoying: return Loc.t("omg you HAVE to come tonight, everyone's asking about you 👀")
            case .bossPassiveAggressive: return Loc.t("Just following up on this again, per my last email 🙂")
            case .intrusiveParent: return Loc.t("Call me back. It's important. Where even are you these days?")
            case .strongPartner: return Loc.t("We need to talk. Tonight. Don't be late.")
            }
        }

        var toneColor: Color {
            switch self {
            case .friendAnnoying: return Theme.Colors.Tone.overEager
            case .bossPassiveAggressive: return Theme.Colors.Tone.passiveAggressive
            case .intrusiveParent: return Theme.Colors.Tone.anxious
            case .strongPartner: return Theme.Colors.Tone.sarcastic
            }
        }
    }
}
