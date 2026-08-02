//
//  LiquidGlassCTAButtonStyle.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 01/08/2026.
//

import SwiftUI

/// The app's primary-CTA button style: the real, native iOS 26 Liquid Glass
/// material (`.glassEffect`) - no hand-drawn border or gradient on top of
/// it, so it reads as the same system glass every other native glass
/// surface in iOS uses. `tint` is passed in by the caller (usually straight
/// from `Theme.Colors`, which itself reads `ThemeManager.shared`), so this
/// re-skins live across Light/Dark/Terminal exactly like every other themed
/// surface - it has no theme awareness of its own.
struct LiquidGlassCTAButtonStyle: ButtonStyle {

    var tint: Color
    var cornerRadius: CGFloat = StaticData.Layout.cornerRadius
    var verticalPadding: CGFloat = 18
    var isInteractive: Bool = true

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .glassEffect(
                .regular.tint(tint).interactive(isInteractive),
                in: shape
            )
            // Without this, the button's actual hit-testable region shrinks
            // to whatever `configuration.label` draws opaquely (the text
            // glyphs), not the full glass card - on a real device (where
            // taps rarely land pixel-perfectly on a glyph the way a mouse
            // click can) that reads as "the button barely responds unless
            // you tap exactly on the text." This makes the whole rounded
            // card tappable, matching what it visually looks like.
            .contentShape(shape)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
