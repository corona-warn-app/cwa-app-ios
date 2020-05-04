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

    private var queue: DispatchQueue
    private var sessionStartTime: Date?

    private static let numberOfPastDaysRelevantForDetection = 14  // TODO: Move to config class / .plist

    init() {
        self.queue = DispatchQueue(label: "com.sap.exposureDetection")
    }

    func detectExposureIfNeeded() {
        // Check the timeframe since last succesfull download of a package.
        // FIXME: Enable check after testing
        //        if !checkLastEVSession() {
        //            return  // Avoid DDoS by allowing only one request per hour
        //        }

        self.sessionStartTime = Date()  // will be used once the session succeeded

        // Prepare parameter for download task
        let timeframe = timeframeToFetchKeys()
        Server.shared.getExposureConfiguration { result in
            switch result {

            case .success(let config):
                let pm = PackageManager(mode: .development)
                pm.diagnosisKeys(since: timeframe) { result in
                    switch result {
                    case .success(let keys):
                        self.startExposureDetectionSession(configuration: config, diagnosisKeys: keys)
                    case .failure(_):
                        // TODO
                        print("fail")
                    }
                }
            case .failure(_):
                fatalError("implementation missing")
            }

        }


    }

    // MARK: - Private helper methods
    private func timeframeToFetchKeys() -> Date {
        // Case 1: First request -> Fetch last 14 days
        // Case 2: Request within 2 weeks from last request -> just format timestamp
        // Case 3: Last request older than upper threshold -> limit to threshold
        let numberOfRelevantDays = type(of: self).numberOfPastDaysRelevantForDetection
        let now = Date()
        return Calendar.current.date(byAdding: .day, value: -numberOfRelevantDays, to: now) ?? now
    }

    private func checkLastEVSession() -> Bool {
        guard let dateLastExposureDetection = PersistenceManager.shared.dateLastExposureDetection else{
            return true  // No date stored -> first session
        }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour], from: dateLastExposureDetection, to: Date())
        let hoursSinceLastRequest = dateComponents.hour ?? 0

        // Only allow one request per hour
        return hoursSinceLastRequest > 1
    }

}

// MARK: - Exposure Detection Session
extension ExposureDetectionService {
    private func startExposureDetectionSession(
        configuration: ENExposureConfiguration,
        diagnosisKeys: [ENTemporaryExposureKey]
    ) {
        let session = ENExposureDetectionSession()
        session.configuration = configuration
        session.activate() { error in
            if error != nil {
                // Handle error
                return
            }
            // Call addDiagnosisKeys with up to maxKeyCount keys + wait for completion
            self.queue.async {
                let result = self.addKeys(session, diagnosisKeys)
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        let notification = Notification(name: Notification.Name.exposureDetectionSessionDidFail, object: error, userInfo: nil)
                        NotificationCenter.default.post(notification)
                    case .success(_):
                        // Get result from session
                        session.finishedDiagnosisKeys { (summary, error) in
                            // This is called on the main queue
                            guard error == nil else {
                                let notification = Notification(name: Notification.Name.exposureDetectionSessionDidFail, object: error, userInfo: nil)
                                NotificationCenter.default.post(notification)
                                return
                            }
                            guard let summary = summary else {
                                return
                            }

                            session.getExposureInfo(withMaximumCount: 100) { (info, done, exposureError) in
                                if let exposureError = exposureError {
                                    print("getExposureInfo failed: \(exposureError)")
                                    return
                                }
                                print("got getExposureInfo: \(String(describing: info))")
                            }

                            // Update timestamp of last successfull session
                            if self.sessionStartTime != nil {
                                PersistenceManager.shared.dateLastExposureDetection = self.sessionStartTime!
                            }

                            // TODO: Send exposures / summary to PersistenceManager
                        }
                    }
                }

            }
        }
    }

    func addKeys(_ session: ENExposureDetectionSession, _ keys: [ENTemporaryExposureKey]) -> Result<Void, Error> {
        var index = 0
        var resultError: Error?
        while index < keys.count {
            let semaphore = DispatchSemaphore(value: 0)
            let endIndex = index + session.maximumKeyCount > keys.count ? keys.count : index + session.maximumKeyCount
            let slice = keys[index..<endIndex]

            session.addDiagnosisKeys(Array(slice)) { (error) in
                // This is called on the main queue
                guard error == nil else {
                    resultError = error
                    semaphore.signal()
                    return
                }
                semaphore.signal()
            }
            semaphore.wait()
            if let resultError = resultError {
                return .failure(resultError)
            }
            index += session.maximumKeyCount
        }
        return .success(Void())
    }
}
