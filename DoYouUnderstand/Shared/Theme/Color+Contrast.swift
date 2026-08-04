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

    /// WCAG relative luminance / contrast ratio against another color -
    /// used to measure (and fix) legibility programmatically instead of
    /// eyeballing hex values.
    func contrastRatio(against background: Color) -> CGFloat {
        func luminance(of color: Color) -> CGFloat {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
            func linearize(_ channel: CGFloat) -> CGFloat {
                channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
        }

        let l1 = luminance(of: self)
        let l2 = luminance(of: background)
        let (lighter, darker) = l1 > l2 ? (l1, l2) : (l2, l1)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Darkens this color - reducing brightness while preserving its hue
    /// and saturation, so it stays recognizably "the same color" - until it
    /// reaches `minContrastRatio` against `background`, or hits a brightness
    /// floor. A no-op if the color already clears the bar.
    func adjustedForContrast(against background: Color, minContrastRatio: CGFloat = 4.5) -> Color {
        guard contrastRatio(against: background) < minContrastRatio else { return self }

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

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
}
