//
//  DebugBypass.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 04/08/2026.
//

import Foundation

/// A fixed token, present only in `#if DEBUG` builds (never in a TestFlight
/// or App Store Release build), that lets local development exhaust the
/// server-side daily usage cap without ever hitting it - the Edge Function
/// skips `checkAndIncrementUsage` entirely when it sees this exact value in
/// `DEBUG_BYPASS_SECRET`. Unlike the Gemini key, this token IS committed to
/// the repo, since it only ever matters for a locally-built Debug binary you
/// run yourself - it's never reachable from a distributed build.
enum DebugBypass {
    #if DEBUG
    static let token: String? = "b307b43acdf90a2807262684e0eef5fdcf51ab11f1ad5367"
    #else
    static let token: String? = nil
    #endif
}
