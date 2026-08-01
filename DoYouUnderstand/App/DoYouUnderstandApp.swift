//
//  DoYouUnderstandApp.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 08/06/2026.
//

import SwiftUI
import RevenueCat

@main
struct DoYouUnderstandApp: App {

    init() {
        AppFonts.registerAll()

        Purchases.configure(withAPIKey: "test_ybbEzgFJTkspJWETuhYDIroaZiy")
        Task {
            await SubscriptionManager.shared.start()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
