//
//  TactileHoldHapticEngine.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 02/08/2026.
//

import CoreHaptics
import UIKit

/// Drives the press-and-hold tactile feedback for `TactileHoldStepView`: an
/// instant tap the moment the finger lands, a continuous rumble whose
/// intensity/sharpness ramp up with progress as the hold fills, and a
/// single sharp, maximum-intensity transient "click" the moment it
/// completes. Falls back to a plain `UIImpactFeedbackGenerator` wherever
/// `CHHapticEngine` isn't supported - the Simulator has no Taptic Engine at
/// all, so the crescendo itself can only be felt on a physical device.
@MainActor
final class TactileHoldHapticEngine {

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private let touchDownGenerator = UIImpactFeedbackGenerator(style: .rigid)

    init() {
        touchDownGenerator.prepare()
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            engine.resetHandler = { [weak engine] in try? engine?.start() }
            engine.stoppedHandler = { _ in }
            try engine.start()
            self.engine = engine
        } catch {
            engine = nil
        }
    }

    /// Fires the instant "you touched the screen" tap and starts the
    /// continuous rumble that `updateProgress(_:)` then ramps.
    func touchDown(duration: TimeInterval) {
        touchDownGenerator.impactOccurred()

        guard let engine, continuousPlayer == nil else { return }
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.12)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: duration + 0.5
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            continuousPlayer = player
        } catch {
            continuousPlayer = nil
        }
    }

    /// Ramps the ongoing rumble's intensity and sharpness with how far the
    /// hold has filled (0...1) - the "crescendo" that builds as the circle
    /// expands.
    func updateProgress(_ progress: Double) {
        guard let continuousPlayer else { return }
        let intensity = CHHapticDynamicParameter(
            parameterID: .hapticIntensityControl,
            value: Float(0.12 + 0.88 * progress),
            relativeTime: 0
        )
        let sharpness = CHHapticDynamicParameter(
            parameterID: .hapticSharpnessControl,
            value: Float(0.1 + 0.8 * progress),
            relativeTime: 0
        )
        try? continuousPlayer.sendParameters([intensity, sharpness], atTime: CHHapticTimeImmediate)
    }

    /// Early release - didn't complete the hold. Silences the rumble
    /// immediately rather than letting it ring out on its own.
    func cancel() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil
    }

    /// The hold completed: stop the rumble and land one sharp, maximum-
    /// intensity transient - deliberately not just another impact in the
    /// same style as the rumble, so it reads as a distinct "click" rather
    /// than a continuation of what came before it.
    func complete() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil

        guard let engine else {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            return
        }
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
