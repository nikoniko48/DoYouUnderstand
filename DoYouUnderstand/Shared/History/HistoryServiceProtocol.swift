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

    /// Overwrites an existing record's payload in place (same `id`, same
    /// `timestamp`) - used by screens like Refine that keep refining the
    /// same entry across a session and want later results to replace the
    /// earlier ones rather than piling up as separate Dashboard rows.
    func update(id: String, payload: HistoryPayload)

    func delete(id: String)
}
