//
//  SettingsViewModel.swift
//  ENA
//
//  Created by Zildzic, Adnan on 22.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class SettingsViewModel {
    var tracing: Main
    var notifications: Main
    var reset: String

    init(tracing: Main, notifications: Main, reset: String) {
        self.tracing = tracing
        self.notifications = notifications
        self.reset = reset
    }

    static let model = SettingsViewModel(
        tracing: Main(
            icon: ("UmfeldaufnahmeAktiv_Primary1", false),
            description: AppStrings.Settings.tracingLabel,
            stateActive: AppStrings.Settings.trackingStatusActive,
            stateInactive: AppStrings.Settings.trackingStatusInactive
        ),
        notifications: Main(
            icon: ("Mitteilungen", false),
            description: AppStrings.Settings.notificationLabel,
            stateActive: AppStrings.Settings.notificationStatusActive,
            stateInactive: AppStrings.Settings.notificationStatusInactive
        ),
        reset: AppStrings.Settings.resetLabel
    )
}

extension SettingsViewModel {
    struct Main {
        let icon: (imageName: String, isSystem: Bool)
        let description: String
        var state: String?

        let stateActive: String
        let stateInactive: String

        mutating func setState(state: Bool) {
            self.state = state ? stateActive : stateInactive
        }
    }
}
