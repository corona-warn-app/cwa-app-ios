//
//  SignedPayloadStore.swift
//  ENA
//
//  Created by Kienle, Christian on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

protocol SignedPayloadProviding {
    func serializedSignedPayload() -> Data
}

extension Data: SignedPayloadProviding {
    func serializedSignedPayload() -> Data { self }
}

final class SignedPayloadStore {
    // MARK: Creating

    // MARK: Properties
    private var signedPayloadsByDay = [String: SignedPayloadProviding]()

    // Stores all downloaded hours mapped by day.
    // The data stored here looks like this:
    // 2020-05-01
    //     0: keys for that day at hour 0
    //     1: keys for that day at hour 1
    //     n: keys for that day at hour n
    // 2020-05-02
    //     0: keys for that day at hour 0
    //     1: keys for that day at hour 1
    //     n: keys for that day at hour n
    //
    // etc
    //
    // This means that this store can be used to store the hours of any given day.
    // It is up to the consumer to find the correct day.
    // It is also up to the consumer of this class to clean unwanted hourly data.
    private var signedPayloadsByHour = [String: [Int: SignedPayloadProviding]]()

    // MARK: Working with Days
    func missingDays(remoteDays: Set<String>) -> Set<String> {
        remoteDays.subtracting(Set(signedPayloadsByDay.keys))
    }

    func add(day: String, signedPayload: SignedPayloadProviding) {
        signedPayloadsByDay[day] = signedPayload
    }

    func signedPayload(for day: String) -> SignedPayloadProviding? {
        signedPayloadsByDay[day]
    }

    func allDailySignedPayloads() -> [SignedPayloadProviding] {
        Array(signedPayloadsByDay.values)
    }

    func hourlySignedPayloads(day: String) -> [SignedPayloadProviding] {
        Array(signedPayloadsByHour[day, default: [:]].values)
    }

    // MARK: Working with Hours
    func add(hour: Int, day: String, signedPayload: SignedPayloadProviding) {
        var diagnosisKeysByHour = signedPayloadsByHour[day, default: [:]]
        diagnosisKeysByHour[hour] = signedPayload
        signedPayloadsByHour[day] = diagnosisKeysByHour
    }

    func missingHours(day: String, remoteHours: Set<Int>) -> Set<Int> {
        let signedPayloads = signedPayloadsByHour[day, default: [:]]
        let localHours = Set(signedPayloads.keys)
        return remoteHours.subtracting(localHours)
    }
}
