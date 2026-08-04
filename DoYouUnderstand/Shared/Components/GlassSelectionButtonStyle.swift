//
//  GlassSelectionButtonStyle.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//

import SwiftUI

/// The app's recurring "selectable glass tile" look: a plain `.glassEffect`
/// surface that picks up a very subtle color tint when `isSelected`, plus
/// whatever native `.interactive()` press-grow the glass material gives it.
///
/// This used to mark selection with a colored ring drawn as a separate
/// `.overlay` instead of a tint - which meant it never automatically shared
/// in whatever `.interactive()` did to the fill while held, since it was a
/// second, independent layer on top of the glass's own render pass. Several
/// attempts to keep the ring in sync (scaling it together with the tile,
/// then giving it its own animatable frame size, then reading that frame's
/// geometry synchronously instead of through delayed `@State`) each fixed
/// one specific desync cause, but a small delay kept showing up somewhere
/// else - there was always another gap between "whatever the glass renders"
/// and "whatever our separate ring layer draws," because they were always
/// two different things being kept in sync by hand rather than one thing.
/// A tint baked directly into the same `.glassEffect(...)` call that already
/// renders the native press-grow doesn't have this problem *by construction*
/// - it's not a second layer trying to track the first, it's part of the
/// same one, so there's nothing left to desync.
struct GlassSelectionButtonStyle<S: InsettableShape>: ButtonStyle {

    let shape: S
    let isSelected: Bool
    // The tint's own base color when selected - also used as the fallback
    // source for `selectedTint` below via `tintColor.opacity(tintOpacity)`.
    var tintColor: Color = Theme.Colors.Main.primary
    var tintOpacity: Double = 0.14
    // An explicit override for the selected-state tint (e.g. the checkout
    // sheet's plan rows want their own specific accent wash) - `nil` uses
    // `tintColor.opacity(tintOpacity)` instead.
    var selectedTint: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .glassEffect(
                isSelected
                    ? .regular.tint(selectedTint ?? tintColor.opacity(tintOpacity)).interactive()
                    : .regular.interactive(),
                in: shape
            )
            .contentShape(shape)
    }
}
