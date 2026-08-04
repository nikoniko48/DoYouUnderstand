//
//  Color+Contrast.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 03/08/2026.
//
//  The tone-palette colors (Classic/Pastel/Neon/Mono) were originally tuned
//  by eye against a dark background and never checked against Light theme's
//  near-white one - measuring found most of them well below WCAG's 4.5:1
//  minimum there (several under 2:1, effectively invisible). Rather than
//  hand-picking a second full 16-tone color map per palette, `TonePaletteChoice`
//  darkens each color at read time via `adjustedForContrast`, only when the
//  active theme's background actually needs it.

import SwiftUI
import UIKit

extension Color {

    /// WCAG relative luminance (0 = black, 1 = white) - the shared building
    /// block for `contrastRatio(against:)` below, and for `adjustedForContrast`
    /// deciding which direction to search in.
    var relativeLuminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        func linearize(_ channel: CGFloat) -> CGFloat {
            channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    /// WCAG contrast ratio against another color - used to measure (and fix)
    /// legibility programmatically instead of eyeballing hex values.
    func contrastRatio(against background: Color) -> CGFloat {
        let l1 = relativeLuminance
        let l2 = background.relativeLuminance
        let (lighter, darker) = l1 > l2 ? (l1, l2) : (l2, l1)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Nudges this color's brightness - and, only if brightness alone can't
    /// get there, its saturation too - until it reaches `minContrastRatio`
    /// against `background`. A no-op if the color already clears the bar.
    ///
    /// A color can fail contrast either by being too close in luminance to a
    /// *light* background (needs to go darker) or to a *dark* one (needs to
    /// go lighter) - this used to only ever darken, which was silently
    /// backwards for any color that failed against a dark background (Dark/
    /// Terminal's near-black `background`): darkening a color that's already
    /// too dark to read against black only makes it worse, walking it all
    /// the way to the floor instead of ever fixing it (e.g. Classic's
    /// `savage` and Neon's deep blue/violet tones were essentially invisible
    /// there before this fix). `background`'s own luminance now picks the
    /// direction. Brightening can still fall short for fully-saturated deep
    /// hues (blue/violet have the lowest luminance weight of any hue at a
    /// given brightness) even at brightness 1 - desaturating slightly toward
    /// white after that closes the remaining gap while staying recognizably
    /// the same hue.
    func adjustedForContrast(against background: Color, minContrastRatio: CGFloat = 4.5) -> Color {
        guard contrastRatio(against: background) < minContrastRatio else { return self }

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        guard background.relativeLuminance <= 0.5 else {
            var candidateBrightness = brightness
            while candidateBrightness > 0.1 {
                candidateBrightness -= 0.02
                let candidate = Color(hue: hue, saturation: saturation, brightness: candidateBrightness)
                if candidate.contrastRatio(against: background) >= minContrastRatio {
                    return candidate
                }
            }
            return Color(hue: hue, saturation: saturation, brightness: 0.1)
        }

        var candidateBrightness = brightness
        while candidateBrightness < 1.0 {
            candidateBrightness = min(candidateBrightness + 0.02, 1.0)
            let candidate = Color(hue: hue, saturation: saturation, brightness: candidateBrightness)
            if candidate.contrastRatio(against: background) >= minContrastRatio {
                return candidate
            }
        }

        var candidateSaturation = saturation
        while candidateSaturation > 0.0 {
            candidateSaturation -= 0.02
            let candidate = Color(hue: hue, saturation: candidateSaturation, brightness: 1.0)
            if candidate.contrastRatio(against: background) >= minContrastRatio {
                return candidate
            }
        }
        return Color(hue: hue, saturation: 0, brightness: 1.0)
    }
}
