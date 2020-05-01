//
//  ExposureDetectionService.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

class ExposureDetectionService {

    private weak var delegate: ExposureDetectionServiceDelegate?

    @UserDefaultsStorage(key: "lastProcessedPackageTime", defaultValue: nil)
    static var lastProcessedPackageTime: Date?

    init(delegate: ExposureDetectionServiceDelegate?) {
        self.delegate = delegate
    }

    func verifyExposureIfNeeded() {
        // Check the timeframe since last succesfull download of a package.
        if !checkLastEVSession() {
            return  // Avoid DDoS by allowing only one request per hour
        }

        // Prepare parameter for download task
        let requestParam = formatPackageRequestName()

        let pm = PackageManager()
        pm.downloadDiagnosisKeys(urlSuffix: requestParam)

    }

    // MARK: - Private helper methods
    private func formatPackageRequestName() -> String {
        // Case 1: First request -> Fetch last 14 days
        // Case 2: Request within 2 weeks from last request -> just format timestamp
        // Case 3: Last request older than upper threshold -> limit to threshold
        return "06-03-22"
    }

    private func checkLastEVSession() -> Bool {
        guard let lastProcessedPackageTime = Self.lastProcessedPackageTime else{
            return true  // No date stored -> first session
        }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour], from: lastProcessedPackageTime, to: Date())
        let hoursSinceLastRequest = dateComponents.hour ?? 0

        // Only allow one request per hour
        return hoursSinceLastRequest > 1
    }

}

// MARK: - Exposure Detection Session
extension ExposureDetectionService {
    func startExposureDetectionSession() {
        let session = ENExposureDetectionSession()

        session.activate() { error in
            if error != nil {
                // Handle error
                return
            }
        }

        // Call addDiagnosisKeys with up to maxKeyCount keys. (Loop)

        // Wait for the completion handler for addDiagnosisKeys to be invoked with a nil error.

        // Repeat the previous two steps until all keys are provided to the system or an error occurs.

        // Call finishedDiagnosisKeysWithCompletion.

        // Wait for the completion handler for finishedDiagnosisKeysWithCompletion to be invoked with a nil error

    }
}
