//
//  MockExposureManager.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
@testable import ENA

final class MockExposureManager {
    typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

    // MARK: Properties
    let exposureNotificationError: ExposureNotificationError?
    let diagnosisKeysResult: MockDiagnosisKeysResult?

    // MARK: Creating a Mocked Manager
    init(
        exposureNotificationError: ExposureNotificationError?,
        diagnosisKeysResult:  MockDiagnosisKeysResult?
    ) {
        self.exposureNotificationError = exposureNotificationError
        self.diagnosisKeysResult = diagnosisKeysResult
    }


}

extension MockExposureManager: ExposureManager {
    func invalidate() {}
    
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
