//
//  AppTheme.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI
import UIKit

enum Theme {
    
    enum Colors {
        
        enum Main {
            static let background = Color("AppBackground")
            static let backgroundSecondary = Color("AppBackgroundSecondary")
            static let primary = Color("AppPrimary")
            static let borderSubtle = Color("BorderSubtle")
            static let accent = Color("AppAccent")
            static let secondaryAccent = Color("AppSecondaryAccent")
            static let cardSurface = Color("CardSurface")
            static let success = Color("SuccessGreen")
        }
        
        enum Text {
            static let title = Color("TextTitle")
            static let body = Color("TextBody")
            static let highlight = Color("TextHighlight")
            static let muted = Color("TextMuted")
        }
        
        enum Tone {
            static let anxious = Color("ToneAnxious")
            static let condescending = Color("ToneCondescending")
            static let overEager = Color("ToneOverEager")
            static let passiveAggressive = Color("TonePassiveAggressive")
            static let sarcastic = Color("ToneSarcastic")
        }
    }
    
    enum Typography {
        static let hugeTitle = Font.system(size: 22, weight: .heavy)
        static let screenTitle = Font.system(size: 18, weight: .bold)
        static let primaryButton = Font.system(size: 17, weight: .heavy)

        static let biggerText = Font.system(size: 14, weight: .bold)
        static let bodyText = Font.system(size: 13, weight: .medium)
        static let smallBody = Font.system(size: 12, weight: .regular)

        static let badgeLabel = Font.system(size: 11, weight: .heavy)
        static let tinyLabel = Font.system(size: 10, weight: .heavy)
    }
}

extension Color {

    /// Black or white, whichever is more readable on top of this color — for text/icons drawn over a runtime-variable background color (e.g. a tone color) that may itself be white or near-white.
    var contrastingForeground: Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.6 ? .black : .white
    }
}
