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
    let packageManager: PackageManager

    init(_ packageManager: PackageManager? = nil) {
        self.packageManager = packageManager ?? PackageManager(mode: .development)
    }

    func submitSelfExposure(tan: String, completionHandler: @escaping  ExposureSubmissionHandler) {
        let enManager = ExposureManager.shared.manager

        if enManager.exposureNotificationStatus != .active {
            completionHandler(.notActivated)
            return
        }

        enManager.getDiagnosisKeys { keys, error in
            if let error = error {
                completionHandler(self.parseError(error))
                return
            }

            guard let keys = keys else {
                completionHandler(.noKeys)
                return
            }

            self.packageManager.sendDiagnosisKeys(keys, tan: tan) { error in
                completionHandler(error == nil ? nil : self.parseError(error!))
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
