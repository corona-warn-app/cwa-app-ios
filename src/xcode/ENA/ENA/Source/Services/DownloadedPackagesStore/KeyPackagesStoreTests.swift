//
//  DownloadedPackagesStoreTests.swift
//  ENA
//
//  Created by Kienle, Christian on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
@testable import ENA

final class DownloadedPackagesStoreTests: XCTestCase {
    func testMissingDays_EmptyStore() {
        let store = DownloadedPackagesStore()
        XCTAssertEqual(store.missingDays(remoteDays: []), [])
        XCTAssertEqual(store.missingDays(remoteDays: ["a"]), ["a"])
        XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), ["a", "b"])
    }

    func testMissingDays_FilledStore() {
        let store = DownloadedPackagesStore()

        store.set(
            day: "a",
            downloadedPackage:
            SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xa], count: 1)
            )
        )

        XCTAssertEqual(store.missingDays(remoteDays: []), [])
        // we already have "a"
        XCTAssertEqual(store.missingDays(remoteDays: ["a"]), [])

        // we are missing "b"
        XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), ["b"])

        store.set(
            day: "b",
            downloadedPackage:
            SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xb], count: 1)
            )
        )

        // we are not missing anything
        XCTAssertEqual(store.missingDays(remoteDays: ["a", "b"]), [])

        // we are missing c
        XCTAssertEqual(store.missingDays(remoteDays: ["a", "b", "c"]), ["c"])
    }

    func testMissingHours_EmptyStore() {
        let store = DownloadedPackagesStore()
        XCTAssertEqual(
            store.missingHours(day: "a", remoteHours: []),
            []
        )
        XCTAssertEqual(
            store.missingHours(day: "a", remoteHours: [1, 2, 3, 4]),
            [1, 2, 3, 4]
        )
    }

    func testMissingHours_StoreWithDaysButNoRemoteHours() {
        let store = DownloadedPackagesStore()
        store.set(
            day: "a",
            downloadedPackage: SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xb], count: 1)
            )
        )

        XCTAssertEqual(
            store.missingHours(day: "a", remoteHours: []),
            []
        )
    }

    func testMissingHours_StoreWithDaysAndHours() {
        let store = DownloadedPackagesStore()
        store.set(
            day: "a",
            downloadedPackage: SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xb], count: 1)
            )
        )

        XCTAssertEqual(
            store.missingHours(day: "a", remoteHours: []),
            []
        )
        XCTAssertEqual(
            store.missingHours(day: "b", remoteHours: []),
            []
        )
        XCTAssertEqual(
            store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
            [1, 2, 3, 4]
        )

        store.set(
            hour: 1,
            day: "b",
            downloadedPackage:
            SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xb], count: 1)
            )
        )
        XCTAssertEqual(
            store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
            [2, 3, 4]
        )

        store.set(
            hour: 4,
            day: "b",
            downloadedPackage: SAPDownloadedPackage(
                keysBin: Data(bytes: [0xa], count: 1),
                signature: Data(bytes: [0xb], count: 1)
            )
        )
        XCTAssertEqual(
            store.missingHours(day: "b", remoteHours: [1, 2, 3, 4]),
            [2, 3]
        )
    }
}
