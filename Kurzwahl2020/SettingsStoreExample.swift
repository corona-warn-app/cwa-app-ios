//
//  SettingsStore.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 27.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Combine


final class SettingsStoreExample: ObservableObject {
    private enum Keys {
        static let pro = "pro"
        static let sleepGoal = "sleep_goal"
        static let notificationEnabled = "notifications_enabled"
        static let sleepTrackingEnabled = "sleep_tracking_enabled"
        static let sleepTrackingMode = "sleep_tracking_mode"
    }

    private let cancellable: Cancellable
    private let defaults: UserDefaults

    let objectWillChange = PassthroughSubject<Void, Never>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.sleepGoal: 8,
            Keys.sleepTrackingEnabled: true,
            Keys.sleepTrackingMode: SleepTrackingMode.moderate.rawValue
            ])

        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }

    var isNotificationEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.notificationEnabled) }
        get { defaults.bool(forKey: Keys.notificationEnabled) }
    }

    var isPro: Bool {
        set { defaults.set(newValue, forKey: Keys.pro) }
        get { defaults.bool(forKey: Keys.pro) }
    }

    var isSleepTrackingEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.sleepTrackingEnabled) }
        get { defaults.bool(forKey: Keys.sleepTrackingEnabled) }
    }

    var sleepGoal: Int {
        set { defaults.set(newValue, forKey: Keys.sleepGoal) }
        get { defaults.integer(forKey: Keys.sleepGoal) }
    }

    enum SleepTrackingMode: String, CaseIterable {
        case low
        case moderate
        case aggressive
    }

    var sleepTrackingMode: SleepTrackingMode {
        get {
            return defaults.string(forKey: Keys.sleepTrackingMode)
                .flatMap { SleepTrackingMode(rawValue: $0) } ?? .moderate
        }

        set {
            defaults.set(newValue.rawValue, forKey: Keys.sleepTrackingMode)
        }
    }
}


extension SettingsStoreExample {
    func unlockPro() {
        // You can do your in-app transactions here
        isPro = true
    }

    func restorePurchase() {
        // You can do you in-app purchase restore here
        isPro = true
    }
}
