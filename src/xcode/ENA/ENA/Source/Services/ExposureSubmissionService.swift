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

    func submitExposure(with: String, completionHandler: @escaping ExposureSubmissionHandler)
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
    
    typealias RegistrationHandler = (Result<String, Error>) -> Void
    typealias TestResultHandler = (Result<Int, Error>) -> Void
    typealias TANHandler = (Result<String, Error>) -> Void
    
    func getRegistrationToken(forKey key: String, withType type: String, completion completeWith: @escaping RegistrationHandler){
        //save+client request+ delete
        
    }
    func getTANForExposureSubmit(forDevice registrationToken: String, completion completeWith: @escaping TANHandler){
        //alert+ store consent+ clientrequest
        
    }
    
    func getTestResult(forDevice registrationToken: String, completion completeWith: @escaping TestResultHandler) {
        //get testresult and redirect to lab result screen to show the result
    }
    
    func submitExposure(with tan: String, completionHandler: @escaping  ExposureSubmissionHandler) {
        log(message: "Started exposure submission...")
        
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

            self.client.submit(keys: keys, tan: tan) { error in
                if let error = error {
                    logError(message: "Error while submiting diagnosis keys: \(error.localizedDescription)")
                    completionHandler(self.parseServerError(error))
                    return
                }
                log(message: "Successfully completed exposure sumbission.")
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
