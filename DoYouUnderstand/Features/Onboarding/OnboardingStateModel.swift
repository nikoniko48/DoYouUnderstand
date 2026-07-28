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
        var selectedContext: CommunicationContext?
        var selectedGoal: Goal?

        let totalSteps: Int = 3

        init(
            currentStep: Int = 0,
            selectedContext: CommunicationContext? = nil,
            selectedGoal: Goal? = nil
        ) {
            self.currentStep = currentStep
            self.selectedContext = selectedContext
            self.selectedGoal = selectedGoal
        }

        var step: Step {
            Step(rawValue: currentStep) ?? .communicationContext
        }

        var isFinisherStep: Bool {
            step == .finisher
        }

        var isContinueEnabled: Bool {
            switch step {
            case .communicationContext:
                return selectedContext != nil
            case .goal:
                return selectedGoal != nil
            case .finisher:
                return true
            }
        }
    }
}

// MARK: - Steps & Options -

extension OnboardingViewModel.StateModel {

    enum Step: Int, CaseIterable {
        case communicationContext = 0
        case goal = 1
        case finisher = 2
    }

    enum CommunicationContext: String, CaseIterable, Identifiable {
        case workAndSlack = "Work emails and Slack"
        case textingAndDating = "Texting and dating apps"
        case familyGroupChats = "Family group chats"

        var id: String { rawValue }
    }

    enum Goal: String, CaseIterable, Identifiable {
        case decodeMeaning = "Decode what they actually mean"
        case draftReply = "Draft a flawless reply"
        case setBoundaries = "Set firm boundaries"

        var id: String { rawValue }
    }
}
