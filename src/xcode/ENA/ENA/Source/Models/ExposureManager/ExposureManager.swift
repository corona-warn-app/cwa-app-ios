//
//  ExposureManager.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 01.05.20.
//

import ExposureNotification
import Foundation

enum ExposureNotificationError {
    case exposureNotificationRequired // tbc..
}


/**
*   @brief    Wrapper for ENManager to avoid code duplication and to abstract error handling
*/
final class ExposureManager {

    typealias CompletionHandler = ((ExposureNotificationError?) -> Void)

    private let manager: ENManager

    init() {
        self.manager = ENManager()
    }

    /// Activates ENManager and asks user for permission to enable ExposureNotification
    /// If the user declines, completion handler will set the error to exposureNotificationRequired
    func activate(completion: @escaping CompletionHandler) {
        manager.activate { (activationError) in
            if let activationError = activationError {
                self.handleENError(error: activationError, completion: completion)
                return
            }

            if !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { enableError in
                    if let enableError = enableError {
                        self.handleENError(error: enableError, completion: completion)
                        return
                    }
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    /// Wrapper for ENManager.getDiagnosisKeys
    func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        if !self.manager.exposureNotificationEnabled {
            let error = ENError(.notAuthorized)
            completionHandler(nil, error)
        }
        self.manager.getDiagnosisKeys(completionHandler: completionHandler)
    }

    private func handleENError(error: Error, completion: @escaping CompletionHandler) {
        if let error = error as? ENError {
            switch error.code {
            case .notAuthorized:
                print("Failed: \(error.localizedDescription)")
                completion(ExposureNotificationError.exposureNotificationRequired)
            default:
                // TODO: Add missing cases
                fatalError("Not implemented \(error.localizedDescription)")
            }
        } else {
            fatalError("Not implemented \(error.localizedDescription)")
        }
        return
    }

    deinit {
        self.manager.invalidate()
    }
}
