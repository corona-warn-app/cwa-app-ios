//
//  ExposureDetectionService.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

protocol ExposureDetectionServiceDelegate: class {
    func exposureDetectionServiceDidStart(_ service: ExposureDetectionService) -> Void
    func exposureDetectionServiceDidFinish(_ service: ExposureDetectionService, summary: ENExposureDetectionSummary) -> Void
    func exposureDetectionServiceDidFail(_ service: ExposureDetectionService, error: Error) -> Void
}

final class ExposureDetectionService {
    private var queue: DispatchQueue
    private var sessionStartTime: Date?
    private weak var delegate: ExposureDetectionServiceDelegate?
    private let client: Client

    fileprivate static let numberOfPastDaysRelevantForDetection = 14  // TODO: Move to config class / .plist
    fileprivate static let numberCountExposureInfo = 100

    init(delegate: ExposureDetectionServiceDelegate, client: Client) {
        self.queue = DispatchQueue(label: "com.sap.exposureDetection")
        self.delegate = delegate
        self.client = client
    }

    func detectExposureIfNeeded() {
        // Check the timeframe since last succesfull download of a package.
        // FIXME: Enable check after testing
        //        if !checkLastEVSession() {
        //            return  // Avoid DDoS by allowing only one request per hour
        //        }

        self.sessionStartTime = Date()  // will be used once the session succeeded

        // Prepare parameter for download task
        client.exposureConfiguration { configurationResult in
            switch configurationResult {
            case .success(let configuration):
                self.client.fetch() { result in
                    // todo
                    switch result {
                        case .success(let keys):
                            self.startExposureDetectionSession(configuration: configuration, diagnosisKeys: keys)
                        case .failure(_):
                        // TODO
                        print("fail")
                    }
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // MARK: - Private helper methods
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

    private func failWith(error: Error) {
        delegate?.exposureDetectionServiceDidFail(self, error: error)
    }

    private func startExposureDetectionSession(
        configuration: ENExposureConfiguration,
        diagnosisKeys: [ENTemporaryExposureKey]
    ) {
        delegate?.exposureDetectionServiceDidStart(self)

        let session = ENExposureDetectionSession()
        session.configuration = configuration
        session.activate() { error in
            if let error = error {
                self.failWith(error: error)
                return
            }

            // Call addDiagnosisKeys with up to maxKeyCount keys + wait for completion
            self.queue.async {
                let result = self.addKeys(session, diagnosisKeys)
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self.failWith(error: error)
                        return
                    case .success(_):
                        // Get result from session
                        session.finishedDiagnosisKeys { (summary, finishError) in
                            // This is called on the main queue
                            if let finishError = finishError {
                                self.failWith(error: finishError)
                                return
                            }

                            guard let summary = summary else {
                                fatalError("how can this happen apple?")
                            }

                            self.delegate?.exposureDetectionServiceDidFinish(self, summary: summary)

                            session.getExposureInfo(withMaximumCount: type(of: self).numberCountExposureInfo) { (info, done, exposureError) in
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
