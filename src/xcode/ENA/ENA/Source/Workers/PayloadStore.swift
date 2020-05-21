//
//  LocalDatabase.swift
//  ENA
//
//  Created by Bormeth, Marc on 16.05.20.
//

import Foundation
import FMDB
import ExposureNotification

protocol LocalPayloadStore {
    typealias StoredPayload = (data: Data, day: Date, hour: Int?)

    /// Store three-tuple that's fetched from the remote sever on local database
    func storePayload(payload: StoredPayload)

    /// Get three-tuple that has been previously fetched from the remote sever from local database
    /// If anything goes wrong, an emtpy array will be returned
    func fetchPayloads() -> [StoredPayload]

    /// Delete entries that aren't required any longer
    func clean(until date: Date)

}

final class FMDBPayloadStore: LocalPayloadStore {
    private let db: FMDatabase

    init(with url: URL) {
        // Create tables
        let sqlStmt = """
            CREATE TABLE IF NOT EXISTS payloadStore (
                payload BLOB NOT NULL,
                day DATE NOT NULL,
                hour INTEGER
            );
        """

        db = FMDatabase(url: url)
        db.open()
        
        db.executeStatements(sqlStmt)
    }

    func storePayload(payload: StoredPayload) {
        let insertStr = """
            INSERT INTO payloadStore(payload, day, hour)
            VALUES(?, ?, ?);
        """

        if !db.isOpen {
            db.open()
        }

        do {
            try db.executeUpdate(insertStr, values: [payload.data, payload.day, payload.hour ?? NSNull()])
        } catch {
            logError(message: "Failed to store keys in local db: \(error.localizedDescription)")
        }
    }

    func fetchPayloads() -> [StoredPayload] {
        let query = "SELECT payload, day, hour FROM payloadStore"
        var payloads = [StoredPayload]()

        do {
            let result = try db.executeQuery(query, values: nil)
            while result.next() {
                // swiftlint:disable:next force_unwrapping
                let data = result.data(forColumn: "payload")!
                // swiftlint:disable:next force_unwrapping
                let day = result.date(forColumn: "day")!
                let hour = Int(result.int(forColumn: "hour"))
                payloads.append((data, day, hour))
            }
            result.close()
        } catch {
            logError(message: "Failed to fetch payloads from db: \(error.localizedDescription)")
        }
        return payloads  // could also be an empty array
    }

    func storedDays() -> [Date] {
        let query = "SELECT DISTINCT day FROM payloadStore WHERE hour IS NULL;"
        var days = [Date]()

        do {
            let result = try db.executeQuery(query, values: nil)
            while result.next() {
                // swiftlint:disable:next force_unwrapping
                days.append(result.date(forColumn: "day")!)
            }
            result.close()
        } catch {
            logError(message: "Failed to fetch distinct days from db: \(error.localizedDescription)")
        }
        return days
    }

    func clean(until date: Date) {
        let stmt = "DELETE FROM payloadStore WHERE day < ?;"

        do {
            try db.executeUpdate(stmt, values: [date.timeIntervalSince1970])
        } catch {
            // Don't notify, only a clean-up function
            logError(message: "Failed to clean-up db: \(error.localizedDescription)")
        }
    }

    deinit {
        db.close()
    }

}
