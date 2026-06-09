//
//  AppTheme.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 10/06/2026.
//

import SwiftUI

enum Theme {
    
    enum Colors {
        
        enum Main {
            static let background = Color("AppBackground")
            static let backgroundSecondary = Color("AppBackgroundSecondary")
            static let primary = Color("AppPrimary")
            static let accent = Color("AppAccent")
            static let surface = Color("CardSurface")
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
        
        static let bodyText = Font.system(size: 14, weight: .medium)
        static let smallBody = Font.system(size: 13, weight: .regular)
        
        static let badgeLabel = Font.system(size: 11, weight: .semibold)
        static let tinyLabel = Font.system(size: 10, weight: .bold)
    }
}
