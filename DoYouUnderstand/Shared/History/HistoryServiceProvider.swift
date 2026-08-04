//
//  HistoryServiceProvider.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import Foundation

enum HistoryServiceProvider {

    // Flip this single line to switch the whole app between real on-device
    // history storage and in-memory mock/demo data.
    static let shared: HistoryServiceProtocol = {
        // Lets a UI test opt into seeded Dashboard data (there's no way to
        // inject a different `HistoryServiceProtocol` into an already-
        // launched app from outside it) without changing anything about a
        // normal launch, which never passes this argument.
        if ProcessInfo.processInfo.arguments.contains("UI_TEST_USE_MOCK_HISTORY") {
            return MockHistoryService()
        }
        return LocalHistoryService.shared
    }()
    // static let shared: HistoryServiceProtocol = MockHistoryService()
}
