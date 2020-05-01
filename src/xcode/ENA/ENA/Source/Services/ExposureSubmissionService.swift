//
//  ExposureSubmissionService.swift
//  ENA
//
//  Created by Zildzic, Adnan on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

protocol ExposureSubmissionService {
    typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void

    func submitSelfExposure(tan: String, completionHandler: @escaping ExposureSubmissionHandler)
}

class ExposureSubmissionServiceImpl: ExposureSubmissionService {
    let covService: CovService

    init(_ covService: CovService? = nil) {
        self.covService = covService ?? CovServiceImpl()
    }

    func submitSelfExposure(tan: String, completionHandler: @escaping  ExposureSubmissionHandler) {
        let enManager = ENManager()

        let complete: (ExposureSubmissionError?) -> Void = {
            completionHandler($0)
            enManager.invalidate()
        }

        enManager.activate { error in
            if let error = error {
                complete(self.parseError(error))
                return
            }

            if enManager.exposureNotificationStatus != .active {
                complete(.notActivated)
                return
            }

            enManager.getDiagnosisKeys { keys, error in
                if let error = error {
                    complete(self.parseError(error))
                    return
                }

                guard let keys = keys else {
                    complete(.noKeys)
                    return
                }

                self.covService.submitSelfExposure(tan: tan, diagnosisKeys: keys) { error in
                    complete(error == nil ? nil : self.parseError(error!))
                }
            }
        }
    }

    private func parseError(_ error: Error) -> ExposureSubmissionError {
        // TODO: Transform to a meaningful error
        return .other
    }
}

// TODO: Refactor to a separate file
enum ExposureSubmissionError : Error {
    case notActivated
    case noKeys
    case other
}

// TODO: Service stub, remove
protocol CovService {
    func submitSelfExposure(tan: String, diagnosisKeys: [ENTemporaryExposureKey], completionHandler: @escaping (Error?) -> ())
}

class CovServiceImpl: CovService {
    func submitSelfExposure(tan: String, diagnosisKeys: [ENTemporaryExposureKey], completionHandler: @escaping (Error?) -> ()) {
        completionHandler(nil)
    }
}
