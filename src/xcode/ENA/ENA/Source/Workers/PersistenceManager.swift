//
//  PersistenceManager.swift
//  ENA
//


import Foundation

@propertyWrapper
class PersistedAndPublished<Value: Codable> {

    init(key: String, notificationName: Notification.Name, defaultValue: Value) {
        self.key = key
        self.notificationName = notificationName
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                wrappedValue = try JSONDecoder().decode(Value.self, from: data)
            } catch {
                wrappedValue = defaultValue
            }
        } else {
            wrappedValue = defaultValue
        }
    }

    let key: String
    let notificationName: Notification.Name

    var wrappedValue: Value {
        didSet {
            if let encodedValue = try? JSONEncoder().encode(wrappedValue) {
                UserDefaults.standard.set(encodedValue, forKey: key)
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }

    var projectedValue: PersistedAndPublished<Value> { self }
}

final class PersistenceManager {
    static let shared = PersistenceManager()

    @PersistedAndPublished(
        key: "isOnboarded",
        notificationName: Notification.Name.isOnboardedDidChange,
        defaultValue: false
    )
    var isOnboarded: Bool

    @PersistedAndPublished(
        key: "dateLastExposureDetection",
        notificationName: Notification.Name.dateLastExposureDetectionDidChange,
        defaultValue: nil
    )
    var dateLastExposureDetection: Date?

    @PersistedAndPublished(
        key: "allowsCellularUse",
        notificationName: Notification.Name.permissionCellularUseDidChange,
        defaultValue: true
    )
    var allowsCellularUse: Bool
}
