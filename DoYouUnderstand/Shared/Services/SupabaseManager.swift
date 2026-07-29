//
//  SupabaseManager.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 09/06/2026.
//

import Foundation

enum SupabaseManager {

    static let projectURL = URL(string: "https://jhxkfgvwpjzljcrohjfq.supabase.co")!
    static let anonKey = "sb_publishable_RJK3oH9hooe4dBrp8tZQBQ_irMMJCAi"

    static func functionURL(named name: String) -> URL {
        projectURL.appendingPathComponent("functions/v1/\(name)")
    }
}
