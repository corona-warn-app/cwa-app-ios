//
//  PersistedAndPublished.swift
//  ENA
//
//  Created by Kienle, Christian on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

@propertyWrapper
class PersistedAndPublished<Value> {

    init(key: String, notificationName: Notification.Name, defaultValue: Value) {
        self.key = key
        self.notificationName = notificationName
        if let data = UserDefaults.standard.object(forKey: key) as? Value {
            wrappedValue = data
        } else {
            wrappedValue = defaultValue
        }
    }

    let key: String
    let notificationName: Notification.Name

    var wrappedValue: Value {
        didSet {
            UserDefaults.standard.set(wrappedValue, forKey: key)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    var projectedValue: PersistedAndPublished<Value> { self }
}
