//
//  HistoryServiceProtocol.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//

import Foundation

protocol HistoryServiceProtocol {
    /// All saved records, newest first.
    func fetchAll() -> [HistoryRecord]

    func fetch(id: String) -> HistoryRecord?

    @discardableResult
    func save(_ payload: HistoryPayload) -> HistoryRecord

    func delete(id: String)
}
