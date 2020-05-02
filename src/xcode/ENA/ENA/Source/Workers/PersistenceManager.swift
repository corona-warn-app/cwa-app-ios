//
//  PersistenceManager.swift
//  ENA
//


import Foundation

@propertyWrapper
class Persisted<Value: Codable> {

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

    var projectedValue: Persisted<Value> {
        get { self }
    }
}

class PersistenceManager {

    static let shared = PersistenceManager()

    @Persisted(key: "isOnboarded", notificationName: .init("PersistenceManagerIsOnboardedDidChange"), defaultValue: true)
    var isOnboarded: Bool

    @Persisted(key: "dateLastExposureDetection", notificationName: .init("PersistenceManagerDateLastExposureDetectionDidChange"), defaultValue: nil)
    var dateLastExposureDetection: Date?

}
