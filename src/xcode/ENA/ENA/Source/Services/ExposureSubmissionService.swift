//
//  ExposureSubmissionService.swift
//  ENA
//
//  Created by Zildzic, Adnan on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

enum DeviceRegistrationKey {
    case teleTan(String)
    case guid(String)
}

enum TestResult: Int {
    case pending = 0
    case negative = 1
    case positive = 2
    case invalid = 3
}

protocol ExposureSubmissionService {
    typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void
    typealias RegistrationHandler = (Result<String, ExposureSubmissionError>) -> Void
    typealias TestResultHandler = (Result<TestResult, ExposureSubmissionError>) -> Void
    typealias TANHandler = (Result<String, ExposureSubmissionError>) -> Void
    
    func submitExposure(with: String, completionHandler: @escaping ExposureSubmissionHandler)
    func getRegistrationToken(forKey deviceRegistrationKey: DeviceRegistrationKey,
                              completion completeWith: @escaping RegistrationHandler)
    func getTANForExposureSubmit(hasConsent: Bool,
                                 completion completeWith: @escaping TANHandler)
    func getTestResult(_ completeWith: @escaping TestResultHandler)
    func hasRegistrationToken() -> Bool
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
    
    func hasRegistrationToken() -> Bool {
        return store.registrationToken != nil
    }
    
    func getTestResult(_ completeWith: @escaping TestResultHandler) {
        guard let registrationToken = store.registrationToken else {
            completeWith(.failure(.other))
            return
        }
        
        client.getTestResult(forDevice: registrationToken) { result in
            switch result {
            case .failure:
                completeWith(.failure(.other))
            case .success(let testResult):
                guard let testResult = TestResult(rawValue: testResult) else {
                    completeWith(.failure(.other))
                    return
                }
                
                completeWith(.success(testResult))
            }
        }
    }

    /// Stores the provided key, retrieves the registration token and deletes the key.
    func getRegistrationToken(forKey deviceRegistrationKey: DeviceRegistrationKey,
                              completion completeWith: @escaping RegistrationHandler) {
        store(key: deviceRegistrationKey)
        let (key, type) = getKeyAndType(for: deviceRegistrationKey)
        client.getRegistrationToken(forKey: key, withType: type) { result in
            switch result {
            case .failure(let error):
                completeWith(.failure(.other))
            case .success(let registrationToken):
                self.store.registrationToken = registrationToken
                self.delete(key: deviceRegistrationKey)
                completeWith(.success(registrationToken))
            }
        }
    }
    
    func getTANForExposureSubmit(hasConsent: Bool,
                                 completion completeWith: @escaping TANHandler) {
        //alert+ store consent+ clientrequest
        store.devicePairingConsentAccept = hasConsent
        
        if !store.devicePairingConsentAccept {
            completeWith(.failure(.noConsent))
            return
        }
        
        guard let token = store.registrationToken else {
            completeWith(.failure(.noRegistrationToken))
            return
        }
        
        client.getTANForExposureSubmit(forDevice: token) { result in
            switch result {
            case .failure(let failure):
                completeWith(.failure(.other))
            case .success(let tan):
                self.store.tan = tan
                completeWith(.success(tan))
            }
        }
    }
    
    private func getKeyAndType(for key: DeviceRegistrationKey) -> (String, String) {
        switch key {
        case .guid(let guid):
            return (Hasher.sha256(guid), "GUID")
        case .teleTan(let teleTan):
            // teleTAN should NOT be hashed, is for short time
            // usage only.
            return (teleTan, "TELETAN")
        }
    }

    private func store(key: DeviceRegistrationKey) {
        switch key {
        case .guid(let testGUID):
            self.store.testGUID = testGUID
        case .teleTan(let teleTan):
            self.store.teleTan = teleTan
        }
    }

    private func delete(key: DeviceRegistrationKey) {
        // TODO: Actually, we want to set the properties to nil.
        // However, the `DevelopmentStore` does not support that.
        switch key {
        case .guid:
            self.store.testGUID = "" // nil
        case .teleTan:
            self.store.teleTan = "" // nil
        }
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
    case noRegistrationToken
    case enNotEnabled
    case noKeys
    case noConsent
    case invalidTan
}
