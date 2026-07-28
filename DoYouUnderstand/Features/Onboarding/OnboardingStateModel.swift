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
        var direction: StepDirection
        var selectedTriggerMessage: TriggerMessage?
        var selectedCopingStyle: CopingStyle?
        var processingMessageIndex: Int

        let totalSteps: Int = 4
        let progressStepCount: Int = 3

        init(
            currentStep: Int = 0,
            direction: StepDirection = .forward,
            selectedTriggerMessage: TriggerMessage? = nil,
            selectedCopingStyle: CopingStyle? = nil,
            processingMessageIndex: Int = 0
        ) {
            self.currentStep = currentStep
            self.direction = direction
            self.selectedTriggerMessage = selectedTriggerMessage
            self.selectedCopingStyle = selectedCopingStyle
            self.processingMessageIndex = processingMessageIndex
        }

        var step: Step {
            Step(rawValue: currentStep) ?? .triggerMessage
        }

        var isProcessingStep: Bool {
            step == .processing
        }

        var isFinisherStep: Bool {
            step == .finisher
        }

        var canSwipeBack: Bool {
            step != .processing && step != .finisher
        }

        var displayStepNumber: Int {
            min(currentStep + 1, progressStepCount)
        }

        var isContinueEnabled: Bool {
            switch step {
            case .triggerMessage:
                return selectedTriggerMessage != nil
            case .copingStyle:
                return selectedCopingStyle != nil
            case .processing, .finisher:
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
    }

    enum StepDirection {
        case forward
        case backward
    }
}

// MARK: - Steps & Options -

extension OnboardingViewModel.StateModel {

    enum Step: Int, CaseIterable {
        case triggerMessage = 0
        case copingStyle = 1
        case processing = 2
        case finisher = 3
    }

    enum TriggerMessage: String, CaseIterable, Identifiable {
        case coldFriendText = "The 'K.' text from a friend"
        case bossEmail = "The 'Per my last email' from a boss"
        case familyGuiltTrip = "The guilt-trip text from family"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .coldFriendText: return "message.fill"
            case .bossEmail: return "briefcase.fill"
            case .familyGuiltTrip: return "house.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .coldFriendText: return "Short, cold, and terrifying"
            case .bossEmail: return "Corporate passive-aggression"
            case .familyGuiltTrip: return "Emotional manipulation at its finest"
            }
        }

        var toneColor: Color {
            switch self {
            case .coldFriendText: return Theme.Colors.Tone.passiveAggressive
            case .bossEmail: return Theme.Colors.Tone.condescending
            case .familyGuiltTrip: return Theme.Colors.Tone.anxious
            }
        }
    }

    enum CopingStyle: String, CaseIterable, Identifiable {
        case stare = "Stare at it for an hour"
        case vent = "Vent to a coworker"
        case draftRisky = "Draft a risky emotional reply"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .stare: return "clock.fill"
            case .vent: return "person.2.fill"
            case .draftRisky: return "flame.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .stare: return "Overthinking every single word"
            case .vent: return "Sending screenshots for backup"
            case .draftRisky: return "Typing what you *really* want to say"
            }
        }

        var toneColor: Color {
            switch self {
            case .stare: return Theme.Colors.Tone.anxious
            case .vent: return Theme.Colors.Tone.overEager
            case .draftRisky: return Theme.Colors.Tone.sarcastic
            }
        }
    }
}
