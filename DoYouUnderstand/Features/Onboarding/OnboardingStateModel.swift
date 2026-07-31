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
        var selectedTheme: AppThemeChoice?
        var selectedTonePalette: TonePaletteChoice?
        var selectedTriggerMessage: TriggerMessage?
        var processingMessageIndex: Int
        var selectedPlan: PricingPlan

        let totalSteps: Int = Step.allCases.count
        let progressStepCount: Int = Step.allCases.count - 1

        init(
            currentStep: Int = 0,
            name: String = "",
            age: Double = 25,
            selectedTheme: AppThemeChoice? = nil,
            selectedTonePalette: TonePaletteChoice? = nil,
            selectedTriggerMessage: TriggerMessage? = nil,
            processingMessageIndex: Int = 0,
            selectedPlan: PricingPlan = .annual
        ) {
            self.currentStep = currentStep
            self.name = name
            self.age = age
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
            case .greeting, .age, .intro, .stats, .processing, .privacy, .finisher:
                return true
            case .name:
                return isNameValid
            case .theme:
                return selectedTheme != nil
            case .triggerMessage, .tactileHold:
                return true
            }
        }

        var processingMessage: String {
            Self.processingMessages[processingMessageIndex % Self.processingMessages.count]
        }

        static let processingMessages: [String] = [
            "Analyzing triggers...",
            "Preparing defense strategies...",
            "Cross-referencing tone patterns...",
            "Decoding emotional undertones..."
        ]

        // 6 ticks x 0.5s = exactly 3.0 seconds.
        static let processingTickCount = 6

        static let statsHeadline = "We've got great news for you."
        // The 31% figure is real (Viber's "21st Century Messaging Etiquette"
        // survey, 2,400 US/UK respondents via Pollfish, 2018). The 92% is our
        // own product claim about app users, not part of that survey.
        static let statsBody = "31% of people say texting is a daily source of stress. Users like you see a 92% reduction in that anxiety within the first two weeks."
        static let statsBeforePercent: Double = 31
        static let statsAfterPercent: Double = 92
        static let statsBeforeLabel = "People Today"
        static let statsAfterLabel = "With Us"
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
        case finisher = 10
    }

    enum PricingPlan: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case annual = "Annual"

        var id: String { rawValue }

        var period: String {
            switch self {
            case .monthly: return "/ month"
            case .annual: return "/ year"
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
            self == .annual ? "BEST VALUE" : nil
        }

        func price(discountActive: Bool) -> String {
            discountActive ? discountedPrice : standardPrice
        }
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
            case .friendAnnoying: return "FROM A FRIEND"
            case .bossPassiveAggressive: return "FROM YOUR BOSS"
            case .intrusiveParent: return "FROM A PARENT"
            case .strongPartner: return "FROM A PARTNER"
            }
        }

        /// The actual example message shown inside the chat bubble.
        var exampleMessage: String {
            switch self {
            case .friendAnnoying: return "omg you HAVE to come tonight, everyone's asking about you 👀"
            case .bossPassiveAggressive: return "Just following up on this again, per my last email 🙂"
            case .intrusiveParent: return "Call me back. It's important. Where even are you these days?"
            case .strongPartner: return "We need to talk. Tonight. Don't be late."
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
