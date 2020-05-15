//
//  PersistedAndPublished.swift
//  ENA
//
//  Created by Kienle, Christian on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
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
