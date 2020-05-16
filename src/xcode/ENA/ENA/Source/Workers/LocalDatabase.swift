//
//  LocalDatabase.swift
//  ENA
//
//  Created by Bormeth, Marc on 16.05.20.
//

import Foundation
import FMDB
import ExposureNotification

final class LocalDatabase {
    typealias FetchDBKeysCompletionHandler = (([ENTemporaryExposureKey]?, Error?) -> Void)

    static let shared = LocalDatabase()

    private let db: FMDatabase

    private init() {
        // swiftlint:disable:next force_try
        let url = try! FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("localdb.sqlite")

        db = FMDatabase(url: url)

        // Create tables
        let sqlStmt = """
            CREATE TABLE IF NOT EXISTS exposureKeys (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                keyData BLOB NOT NULL,
                rollingStartNumber INTEGER NOT NULL,
                rollingPeriod INTEGER NOT NULL,
                transmissionRiskLevel INTEGER NOT NULL
            );
        """
        db.executeStatements(sqlStmt)

    }

    /// Store ENTemporaryExposureKeys on local database
    func addKeys(keys: [ENTemporaryExposureKey]) {
        let insertStr = """
            INSERT INTO exposureKeys(keyData, rollingStartNumber, rollingPeriod, transmissionRiskLevel)
            VALUES(?, ?, ?, ?);
        """

        if !db.isOpen {
            db.open()
        }

        for key in keys {
            do {
                try db.executeUpdate(insertStr, values: [key.keyData, key.rollingPeriod, key.rollingStartNumber, key.transmissionRiskLevel])
            } catch {
                logError(message: "Failed to store keys in local db: \(error.localizedDescription)")
            }
        }

        db.close()
    }

    /// Load all ENTemporaryExposureKeys from local database
    func fetchKeys(with completion: @escaping FetchDBKeysCompletionHandler) {
        let query = "SELECT * FROM exposureKeys"
        var keys = [ENTemporaryExposureKey]()
        let values = [Any]()

        func extractKeys(result: FMResultSet) {
            while result.next() {
                let key = ENTemporaryExposureKey()
                key.keyData = result.data(forColumn: "keyData") ?? Data()
                key.rollingPeriod = UInt32(result.int(forColumn: "rollingPeriod"))
                key.rollingStartNumber = UInt32(result.int(forColumn: "rollingStartNumber"))
                key.transmissionRiskLevel = UInt8(result.int(forColumn: "transmissionRiskLevel"))
                keys.append(key)
            }
            db.close()
            completion(keys, nil)
        }

        if !db.isOpen {
            db.open()
        }

        do {
            let result = try db.executeQuery(query, values: values)
            extractKeys(result: result)
        } catch {
            db.close()
            completion(nil, error)
        }
    }

    /// Delete keys that aren't relevant anymore
    func clean(until date: Date) {
        let threshold: Int32 = Int32(date.timeIntervalSince1970 / 600)
        let stmt = "DELETE FROM exposureKeys WHERE rollingStartNumber < \(threshold);"

        if !db.isOpen {
            db.open()
        }

        do {
            try db.executeUpdate(stmt, values: [Any]())
        } catch {
            // Don't notify, only a clean-up function
            logError(message: "Failed to clean-up db: \(error.localizedDescription)")
        }
        db.close()
    }

}
