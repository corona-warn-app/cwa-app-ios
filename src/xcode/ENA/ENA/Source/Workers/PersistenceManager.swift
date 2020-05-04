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

    var projectedValue: PersistedAndPublished<Value> {
        get { self }
    }
}


/*

 1. ein iphone mit 9 kontakten
 2. wie hoch ist mein risiko?
 3. ich frage beim backend die positiven keys an
 4. jetzt habe ich meine 9 keys mit denen ich kontakt hatte + 5 positive keys
 5. addDiagnosisKeys(5 positive keys)
 6. exporusre info - da stehen nur 3 werte (anzahl kontakte, meta infos zu den kontakten)
 7. hey gibt mir jetzt alle exposures?

 */



final class PersistenceManager {
    private init() {
        clean()
    }

    static let shared = PersistenceManager()

    // TODO: Define init() and call a clean up function of the local storage

    @PersistedAndPublished(
        key: "isOnboarded",
        notificationName: Notification.Name.isOnboardedDidChange,
        defaultValue: true
    )
    var isOnboarded: Bool

    @PersistedAndPublished(
        key: "dateLastExposureDetection",
        notificationName: Notification.Name.dateLastExposureDetectionDidChange,
        defaultValue: nil
    )
    var dateLastExposureDetection: Date?

    @PersistedAndPublished(
        key: "detectedExposures",
        notificationName: Notification.Name.detectedExposuresDidChange,
        defaultValue: []
    )
    var detectedExposures: [Exposure]

    private func clean() {

    }

}
