//
//  BackendConnection.swift
//  ENA
//
//  Created by Bormeth, Marc on 05.05.20.
//

import Foundation
import ExposureNotification

protocol Client {
    typealias ExposureConfigurationCompletionHandler = (Result<ENExposureConfiguration, Error>) -> Void
    typealias SubmitKeysCompletionHandler = (Error?) -> Void
    typealias FetchKeysCompletionHandler = (Result<[ENTemporaryExposureKey], Error>) -> Void

    /// `completion` will be called on the main queue.
    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler)

    /// `completion` will be called on the main queue.
    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler)

    /// `completion` will be called on the main queue.
    func fetch(completion: @escaping FetchKeysCompletionHandler)
}

class MockClient: Client {
    private var submittedKeys = [ENTemporaryExposureKey]()

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
        let exposureConfiguration = ENExposureConfiguration()
        exposureConfiguration.minimumRiskScore = 0
        exposureConfiguration.attenuationWeight = 50
        exposureConfiguration.attenuationScores = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.daysSinceLastExposureWeight = 50
        exposureConfiguration.daysSinceLastExposureScores = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.durationWeight = 50
        exposureConfiguration.durationScores = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.transmissionRiskWeight = 50
        exposureConfiguration.transmissionRiskScores = [1, 2, 3, 4, 5, 6, 7, 8]

        completion(.success(exposureConfiguration))
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        submittedKeys.append(contentsOf: keys)
    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {
        completion(.success(submittedKeys))
    }
}

fileprivate extension Data {
    static func randomKeyData() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        if(SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) != 0) {
            fatalError("this should never happen")
        }
        return Data(bytes)
    }
}
