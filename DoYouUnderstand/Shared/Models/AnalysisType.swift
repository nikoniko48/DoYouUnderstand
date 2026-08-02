//
//  AnalysisType.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 16/06/2026.
//

enum AnalysisType: String, Codable {
    case explain
    case reply

    /// Localized display name - `rawValue` itself stays the fixed English
    /// case name (it's the `Codable` key persisted in on-device history
    /// JSON), so UI that shows this to the user should read this instead.
    var displayName: String {
        switch self {
        case .explain: return Loc.t("Explanation")
        case .reply: return Loc.t("Reply")
        }
    }
}
