//
//  ExposureSubmissionService.swift
//  ENA
//
//  Created by Zildzic, Adnan on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

enum SubmissionAuthorizationType {
    case teleTan(String)
    case guid(String)
}
protocol ExposureSubmissionService {
    typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void

    func submitExposure(with: SubmissionAuthorizationType, completionHandler: @escaping ExposureSubmissionHandler)
}

class ENAExposureSubmissionService: ExposureSubmissionService {
    let manager: ExposureManager
    let client: Client
    let store: Store

    init(manager: ExposureManager, client: Client, store: Store) {
        self.manager = manager
        self.client = client
        self.store = store
    }

    func submitExposure(with type: SubmissionAuthorizationType, completionHandler: @escaping  ExposureSubmissionHandler) {
        log(message: "Started exposure submission...")
        
        // Store teleTan/ guid until we successfully submitted exposure.
        var hash = ""
        switch type {
        case .guid(let guid):
            store.testGUID = guid
            hash = Hasher.sha256(guid)
        case .teleTan(let teleTan):
            store.teleTan = teleTan
            hash = Hasher.sha256(teleTan)
        }
        
        self.manager.accessDiagnosisKeys { keys, error in
            if let error = error {
                logError(message: "Error while retrieving diagnosis keys: \(error.localizedDescription)")
                completionHandler(self.parseExposureManagerError(error as? ExposureNotificationError))
                return
            }

            guard let keys = keys, !keys.isEmpty else {
                completionHandler(.noKeys)
                return
            }

            self.client.submit(keys: keys, tan: hash) { error in
                if let error = error {
                    logError(message: "Error while submiting diagnosis keys: \(error.localizedDescription)")
                    completionHandler(self.parseServerError(error))
                    return
                }
                log(message: "Successfully completed exposure sumbission.")
                
                // Remove teleTan/ testGUID.
                switch type {
                case .guid:
                    self.store.testGUID = nil
                case .teleTan:
                    self.store.teleTan = nil
                }
                
                completionHandler(nil)
            }
        }
    }

    private func parseExposureManagerError(_ error: ExposureNotificationError?) -> ExposureSubmissionError {
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
        case .invalidPayloadOrHeaders,
             .other:
            return .other
        case .invalidTan:
            return .invalidTan
        }
    }
}

enum ExposureSubmissionError: Error {
    case other

    case enNotEnabled
    case noKeys

    case invalidTan
}
