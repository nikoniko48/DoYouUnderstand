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
        var selectedTriggerTone: TriggerTone?
        var selectedCopingStyle: CopingStyle?

        let totalSteps: Int = 3

        init(
            currentStep: Int = 0,
            direction: StepDirection = .forward,
            selectedTriggerTone: TriggerTone? = nil,
            selectedCopingStyle: CopingStyle? = nil
        ) {
            self.currentStep = currentStep
            self.direction = direction
            self.selectedTriggerTone = selectedTriggerTone
            self.selectedCopingStyle = selectedCopingStyle
        }

        var step: Step {
            Step(rawValue: currentStep) ?? .triggerTone
        }

        var isFinisherStep: Bool {
            step == .finisher
        }

        var isContinueEnabled: Bool {
            switch step {
            case .triggerTone:
                return selectedTriggerTone != nil
            case .copingStyle:
                return selectedCopingStyle != nil
            case .finisher:
                return true
            }
        }
    }

    enum StepDirection {
        case forward
        case backward
    }
}

// MARK: - Steps & Options -

extension OnboardingViewModel.StateModel {

    enum Step: Int, CaseIterable {
        case triggerTone = 0
        case copingStyle = 1
        case finisher = 2
    }

    enum TriggerTone: String, CaseIterable, Identifiable {
        case condescending = "Condescending & Bossy"
        case fakeFriendly = "Fake-Friendly & Eager"
        case passiveAggressive = "Pure Passive-Aggressive"

        var id: String { rawValue }

        var emoji: String {
            switch self {
            case .condescending: return "🧐"
            case .fakeFriendly: return "🤩"
            case .passiveAggressive: return "🙃"
            }
        }
    }

    enum CopingStyle: String, CaseIterable, Identifiable {
        case stare = "Stare at it for an hour"
        case vent = "Vent to a coworker"
        case draftRisky = "Draft a risky emotional reply"

        var id: String { rawValue }

        var emoji: String {
            switch self {
            case .stare: return "👀"
            case .vent: return "🗣️"
            case .draftRisky: return "💣"
            }
        }
    }
}
