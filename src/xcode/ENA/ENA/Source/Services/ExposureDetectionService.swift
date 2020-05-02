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

    // FIXME: Use NotificationCenter instead of delegate (Multiple ViewControllers will need the result/summary)
    private weak var delegate: ExposureDetectionServiceDelegate?

    private var queue: DispatchQueue
    private var sessionStartTime: Date?

    @UserDefaultsStorage(key: "lastProcessedPackageTime", defaultValue: nil)
    static var lastProcessedPackageTime: Date?

    init(delegate: ExposureDetectionServiceDelegate?) {
        self.delegate = delegate
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
        let timeframe = getTimeframeToFetchKeys()

        let pm = PackageManager(mode: .development)
        pm.diagnosisKeys(since: timeframe) { result in
            // todo
            switch result {
            case .success(let keys):
                self.startExposureDetectionSession(diagnosisKeys: keys)
            case .failure(_):
                // TODO
                print("fail")
            }
        }

    }

    // MARK: - Private helper methods
    private func getTimeframeToFetchKeys() -> Date {
        // Case 1: First request -> Fetch last 14 days
        // Case 2: Request within 2 weeks from last request -> just format timestamp
        // Case 3: Last request older than upper threshold -> limit to threshold

        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        guard twoWeeksAgo != nil else {
            return Date()
        }
        return twoWeeksAgo!
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
    private func startExposureDetectionSession(diagnosisKeys: [ENTemporaryExposureKey]) {
        let session = ENExposureDetectionSession()

        session.activate() { error in
            if error != nil {
                // Handle error
                return
            }
            // Call addDiagnosisKeys with up to maxKeyCount keys + wait for completion
            self.queue.async {
                let addDiagnosisKeysRetVal = self.addKeys(session, diagnosisKeys)
                DispatchQueue.main.async {
                    guard addDiagnosisKeysRetVal == nil else {
                        self.delegate?.didFailWithError(self, error: addDiagnosisKeysRetVal!)
                        return
                    }
                    // Get result from session
                    session.finishedDiagnosisKeys { (summary, error) in
                        guard error == nil else {
                            self.delegate?.didFailWithError(self, error: error! )
                            return
                        }
                        guard let summary = summary else {
                            return
                        }

                        // Update timestamp of last successfull session
                        if self.sessionStartTime != nil {
                            Self.lastProcessedPackageTime = self.sessionStartTime!
                        }

                        self.delegate?.didFinish(self, result: summary)
                    }
                }

            }
        }
    }

    func addKeys(_ session: ENExposureDetectionSession, _ keys: [ENTemporaryExposureKey]) -> Error? {
        var index = 0
        var returnValue: Error?
        while index < keys.count {
            let semaphore = DispatchSemaphore(value: 0)
            let endIndex = index + session.maximumKeyCount > keys.count ? keys.count : index + session.maximumKeyCount
            let slice = keys[index..<endIndex]

            session.addDiagnosisKeys(Array(slice)) { (error) in
                guard error == nil else {
                    returnValue = error
                    semaphore.signal()
                    return
                }
                semaphore.signal()

            }
            semaphore.wait()
            if returnValue != nil {
                return returnValue
            }
            index += session.maximumKeyCount
        }
        return returnValue
    }
}
