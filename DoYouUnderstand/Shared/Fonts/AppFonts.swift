//
//  AppFonts.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 31/07/2026.
//

import CoreText
import Foundation

/// Registers the app's bundled variable fonts (Space Grotesk, Inter) with
/// CoreText at launch. Registering programmatically - rather than via an
/// `UIAppFonts` Info.plist array - keeps this working regardless of how the
/// target's auto-generated Info.plist is configured.
enum AppFonts {

    private static let fontFileNames = [
        "Inter-VariableFont_opsz,wght",
        "SpaceGrotesk-VariableFont_wght"
    ]

    static func registerAll() {
        for name in fontFileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }
}
