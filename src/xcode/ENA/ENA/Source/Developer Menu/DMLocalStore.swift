/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that contains and manages locally stored app data.
*/

import Foundation
import ExposureNotification

struct Exposure: Codable {
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel.RawValue

    init(exposureInfo: ENExposureInfo) {
        date = exposureInfo.date
        duration = exposureInfo.duration
        totalRiskScore = exposureInfo.totalRiskScore
        transmissionRiskLevel = exposureInfo.transmissionRiskLevel.rawValue
    }

    // For simulation only
    init(date: Date, duration: TimeInterval, totalRiskScore: ENRiskScore, transmissionRiskLevel: ENRiskLevel.RawValue) {
        self.date = date
        self.duration = duration
        self.totalRiskScore = totalRiskScore
        self.transmissionRiskLevel = transmissionRiskLevel
    }
}

struct TestResult: Codable {
    var dateAdministered: Date? // nil if not a verified test
    var dateReceived: Date
    var isShared: Bool
}

@propertyWrapper
class Persisted<Value: Codable> {

    init(userDefaultsKey: String, notificationName: Notification.Name, defaultValue: Value) {
        self.userDefaultsKey = userDefaultsKey
        self.notificationName = notificationName
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                wrappedValue = try JSONDecoder().decode(Value.self, from: data)
            } catch {
                wrappedValue = defaultValue
            }
        } else {
            wrappedValue = defaultValue
        }
    }

    let userDefaultsKey: String
    let notificationName: Notification.Name

    var wrappedValue: Value {
        didSet {
            if let encodedValue = try? JSONEncoder().encode(wrappedValue) {
                UserDefaults.standard.set(encodedValue, forKey: userDefaultsKey)
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }

    var projectedValue: Persisted<Value> {
        get { self }
    }
}
class LocalStore {

    static let shared = LocalStore()

    @Persisted(userDefaultsKey: "isOnboarded", notificationName: .init("LocalStoreIsOnboardedDidChange"), defaultValue: false)
    var isOnboarded: Bool

    @Persisted(userDefaultsKey: "exposures", notificationName: .init("LocalStoreExposuresDidChange"), defaultValue: [])
    var exposures: [Exposure]

    @Persisted(userDefaultsKey: "dateLastPerformedExposureDetection", notificationName: .init("LocalStoreDateLastPerformedExposureDetectionDidChange"), defaultValue: nil)
    var dateLastPerformedExposureDetection: Date?

    @Persisted(userDefaultsKey: "testResults", notificationName: .init("LocalStoreTestResultsDidChange"), defaultValue: [])
    var testResults: [TestResult]
}
