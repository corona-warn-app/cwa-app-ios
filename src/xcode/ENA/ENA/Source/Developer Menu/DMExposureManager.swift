/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that manages a singleton ENManager object.
*/

import Foundation
import ExposureNotification


class ExposureManager {

    let manager = ENManager()

    init() {
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

    static let shared = ExposureManager()
}
