//
//  HistoryItem.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

struct HistoryItem: Identifiable {
    let id: String
    let snippet: String
    let toneBadge: HistoryToneBadge
    let timestamp: String
    let type: AnalysisType

    /// `Text.highlight`/`Main.accent`/`Main.secondaryAccent` are theme-
    /// adaptive tokens driven only by `AppThemeChoice` - reusing one here
    /// meant Reply's badge stayed a fixed blue no matter which tone palette
    /// (Classic/Pastel/Neon/Terminal) was active, unlike Explain/Refine's
    /// `Tone.*` colors which do reskin with the palette. All three now
    /// reuse the same `Tone.*` colors already picked for these modes' icons
    /// on the Input screen, so every one actually changes with the palette
    /// and stays consistent between the two screens.
    var typeColor: Color {
        switch type {
        case .explain:
            return Theme.Colors.Tone.diplomatic
        case .reply:
            return Theme.Colors.Tone.professional
        case .refine:
            // `.professional` (blue) sat almost on top of a plain solid
            // blue right next to it - this warm orange reads as clearly
            // distinct at a glance instead.
            return Theme.Colors.Tone.condescending
        }
    }
}

extension HistoryItem {

    init(record: HistoryRecord) {
        self.init(
            id: record.id,
            snippet: record.snippet,
            toneBadge: record.toneBadge,
            timestamp: Self.formattedTimestamp(record.timestamp),
            type: record.type
        )
    }

    private static func formattedTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        // Explicit, not `Locale.current` - this needs to follow the in-app
        // language picked in Settings, independent of the device's own
        // system language (same reasoning as `LocalizationManager`).
        formatter.locale = LocalizationManager.shared.locale
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
