//
//  LocalHistoryService.swift
//  DoYouUnderstand
//
//  Created by Nikodem Raczka on 29/07/2026.
//
//  On-device JSON persistence. User messages never leave the device through
//  this service - there is no network call here.

import Foundation

final class LocalHistoryService: HistoryServiceProtocol {

    static let shared = LocalHistoryService()

    private let fileURL: URL
    private var records: [HistoryRecord]

    init(fileName: String = "history.json") {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.fileURL = directory.appendingPathComponent(fileName)
        self.records = Self.load(from: fileURL)
    }

    func fetchAll() -> [HistoryRecord] {
        records.sorted { $0.timestamp > $1.timestamp }
    }

    func fetch(id: String) -> HistoryRecord? {
        records.first { $0.id == id }
    }

    @discardableResult
    func save(_ payload: HistoryPayload) -> HistoryRecord {
        let record = HistoryRecord(id: UUID().uuidString, timestamp: Date(), payload: payload)
        records.append(record)
        persist()
        return record
    }

    func delete(id: String) {
        records.removeAll { $0.id == id }
        persist()
    }
}

// MARK: - Disk I/O -

extension LocalHistoryService {

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func load(from url: URL) -> [HistoryRecord] {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([HistoryRecord].self, from: data) else {
            return []
        }
        return decoded
    }
}
