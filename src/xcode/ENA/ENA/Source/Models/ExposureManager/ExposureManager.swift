//
//  ExposureManager.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
import Foundation

final class ExposureManager {

    static let shared = ExposureManager()

    let manager = ENManager()

    private init() {
        manager.activate { _ in
            // Ensure exposure notifications are enabled if we are authorized
            // We could get into this state where we are authorized, but exposure notifications are not enabled if the user initially denied Exposure Notifications during onboarding, but then flipped on the "COVID-19 Exposure Notifications" switch in Settings
            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { _ in
                    // No error handling for attempts to enable on launch
                }
            }
        }
    }

    deinit {
        manager.invalidate()
    }
}
