//
//  HistoryServiceProvider.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

enum HistoryServiceProvider {

    // Flip this single line to switch the whole app between real on-device
    // history storage and in-memory mock/demo data.
    static let shared: HistoryServiceProtocol = LocalHistoryService.shared
    // static let shared: HistoryServiceProtocol = MockHistoryService()
}
