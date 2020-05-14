//
//  MockExposureManager.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
@testable import ENA

class MockExposureManager: ExposureManager {
    typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

    let exposureNotificationError: ExposureNotificationError?
    let diagnosisKeysResult: MockDiagnosisKeysResult?

    init(exposureNotificationError: ExposureNotificationError?, diagnosisKeysResult:  MockDiagnosisKeysResult?) {
        self.exposureNotificationError = exposureNotificationError
        self.diagnosisKeysResult = diagnosisKeysResult
    }

    func activate(completion: @escaping CompletionHandler) {
        completion(exposureNotificationError)
    }

    func enable(completion: @escaping CompletionHandler) {
        completion(exposureNotificationError)
    }

    func disable(completion: @escaping CompletionHandler) {
        completion(exposureNotificationError)
    }

    func preconditions() -> Preconditions {
        return .all
    }

    func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
        return Progress()
    }

    func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
    }

    func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
    }
}
