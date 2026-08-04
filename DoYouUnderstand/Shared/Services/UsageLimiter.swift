//
//  UsageLimiter.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import Foundation

/// A silent, generous daily cap on Gemini-backed calls (explain, reply,
/// tweak, generate-more-tones, refine-analyze, refine-transform) - not a
/// visible "N free scans" quota. The intent is purely to stop a single
/// spamming/abusive user from burning through the Gemini budget, not to
/// ration normal usage, so `dailyLimit` deliberately never appears in any
/// user-facing copy.
///
/// This is a fast, local, `UserDefaults`-based PRE-check only - it lets a
/// well-behaved user see the "come back tomorrow" message instantly, without
/// a network round trip, once they hit the cap in the current install. It is
/// NOT the real enforcement: `UserDefaults` resets on an app reinstall, so
/// the authoritative limit lives server-side in the `analyze-message` Edge
/// Function's `usage_limits` table, keyed by `DeviceIdentifier` (a
/// Keychain-persisted UUID that survives reinstall). Keep this value in sync
/// with `DAILY_USAGE_LIMIT` in `supabase/functions/analyze-message/index.ts`.
enum UsageLimiter {

    private static let dailyLimit = 30

    private static let countKey = "usageLimiterCount"
    private static let dateKey = "usageLimiterDate"

    static var isAtDailyLimit: Bool {
        #if DEBUG
        // Local dev builds shouldn't ever get stopped by this client-side
        // pre-check while testing - the server-side cap in the Edge
        // Function (keyed by `DeviceIdentifier`) still applies regardless.
        return false
        #else
        return currentCount() >= dailyLimit
        #endif
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
