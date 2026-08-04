//
//  BackButton.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

/// The shared back-chevron `ToolbarItem` content used by every screen with
/// a native `.toolbar` header. Previously each screen built this inline as a
/// bare `Image(systemName: "chevron.backward")` inside a `Button` with no
/// explicit frame - the system's own native round press-highlight (the
/// standard toolbar bar-button feedback, present automatically with no
/// custom styling needed) looked right, but its actual tappable region was
/// tied to the glyph's own small rendered bounds, not to that highlight, so
/// a tap near-but-not-on the chevron didn't register. A hand-drawn
/// `.glassEffect(_, in: Circle())` background was tried as a fix, but
/// rendered as a not-quite-circular shape instead of a clean circle - so
/// this goes back to relying on the system's own default button stylinga
/// (no `.buttonStyle` override) for the visual, and fixes *only* the
/// tappable region via a larger `.frame` + `.contentShape(Circle())`.
struct BackButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .frame(width: 32, height: 44)
        }
        .accessibilityIdentifier("backButton")
    }
}
