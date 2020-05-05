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
    let client: Client

    init(client: Client) {
        self.client = client
    }

    func submitSelfExposure(tan: String, completionHandler: @escaping  ExposureSubmissionHandler) {
        let manager = ExposureManager()
        manager.activate { error in
            if let _ = error {
                completionHandler(.notActivated)
                return
            }

            manager.accessDiagnosisKeys { keys, error in
                if let error = error {
                    completionHandler(self.parseError(error))
                    return
                }

                guard let keys = keys else {
                    completionHandler(.noKeys)
                    return
                }

                self.client.submit(keys: keys, tan: tan) { error in
                    completionHandler(error == nil ? nil : self.parseError(error!))
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
