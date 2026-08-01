//
//  UsageLimiter.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// A silent, generous daily cap on Gemini-backed calls (explain, reply,
/// tweak, generate-more-tones) - not a visible "N free scans" quota. The
/// intent is purely to stop a single spamming/abusive user from burning
/// through the Gemini budget, not to ration normal usage, so `dailyLimit`
/// deliberately never appears in any user-facing copy.
enum UsageLimiter {

    private static let dailyLimit = 30

    private static let countKey = "usageLimiterCount"
    private static let dateKey = "usageLimiterDate"

    static var isAtDailyLimit: Bool {
        currentCount() >= dailyLimit
    }

    static func recordUsage() {
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(currentCount() + 1, forKey: countKey)
        UserDefaults.standard.set(today, forKey: dateKey)
    }

    /// Shown instead of running the actual Gemini call once the cap is hit -
    /// deliberately vague about the exact number/reset time.
    static let limitReachedMessage = "You've reached today's usage limit. Please come back tomorrow for more analyses and replies!"

    private static func currentCount() -> Int {
        let storedDate = UserDefaults.standard.object(forKey: dateKey) as? Date ?? .distantPast
        guard Calendar.current.isDateInToday(storedDate) else { return 0 }
        return UserDefaults.standard.integer(forKey: countKey)
    }
}
