//
//  ExposureManager.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 01.05.20.
//

import ExposureNotification
import Foundation

class ExposureManager {
    private var manager: ENManager?

    init() {
        self.manager = ENManager()
    }

    func activate(completion: ((Error?) -> Void)?) {
        manager!.activate { (activationError) in
            if let activationError = activationError {
                completion?(activationError)
                return
            }

            if !self.manager!.exposureNotificationEnabled {
                self.manager!.setExposureNotificationEnabled(true) { enableError in
                    if let enableError = enableError {
                        completion?(enableError)
                        return
                    }
                    completion?(nil)
                }
            } else {
                completion?(nil)
            }
        }
    }

    func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        self.manager!.getDiagnosisKeys(completionHandler: completionHandler)
    }

    deinit {
        self.manager!.invalidate()
        self.manager = nil
    }
}
