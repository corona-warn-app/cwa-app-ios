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

    func submitExposure(tan: String, completionHandler: @escaping ExposureSubmissionHandler)
}

class ExposureSubmissionServiceImpl: ExposureSubmissionService {
    let client: Client

    init(client: Client) {
        self.client = client
    }

    func submitExposure(tan: String, completionHandler: @escaping  ExposureSubmissionHandler) {
        log(message: "Started exposure submission...")

        let manager = ExposureManager()
        manager.activate { error in
            if let error = error {
                log(message: "Exposure notification service not activated.", level: .warning)
                completionHandler(self.parseExposureManagerError(error))
                return
            }

            manager.accessDiagnosisKeys { keys, error in
                if let error = error {
                    logError(message: "Error while retrieving diagnosis keys: \(error.localizedDescription)")
                    completionHandler(self.parseExposureManagerError(error as? ExposureNotificationError)) // TODO: Remove the cast after a meningful error is returned from ExposureManager
                    return
                }

                guard let keys = keys, !keys.isEmpty else {
                    completionHandler(.noKeys)
                    return
                }

                self.client.submit(keys: keys, tan: tan) { error in
                    if let error = error {
                        logError(message: "Error while submitting diagnosis keys: \(error.localizedDescription)")
                    }

                    log(message: "Successfully completed exposure sumbission.")
                    completionHandler(error == nil ? nil : self.parseServerError(error!))
                }
            }
        }
    }

    private func parseExposureManagerError(_ error: ExposureNotificationError?) -> ExposureSubmissionError {
        // TODO: Remove this and add further cases to the switch below,
        // after a meningful error is returned from ExposureManager for accessDiagnosisKeys
        guard let enError = error else {
            return .other
        }

        switch enError {
        case .exposureNotificationRequired, .exposureNotificationAuthorization:
            return .enNotEnabled
        }
    }

    private func parseServerError(_ error: SubmissionError) -> ExposureSubmissionError {
        switch error {
        case .generalError, .invalidPayloadOrHeaders:
            return .other
        case .invalidTan:
            return .invalidTan
        case .networkError:
            return .networkError
        }
    }
}

enum ExposureSubmissionError: Error {
    case other

    case enNotEnabled
    case noKeys

    case invalidTan
    case networkError

}
