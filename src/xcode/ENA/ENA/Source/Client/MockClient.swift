//
//  MockClient.swift
//  ENA
//
//  Created by Kienle, Christian on 08.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

class MockClient: Client {
    // MARK: Creating a Mock Client
    init(submittedKeysFileURL: URL) {
        self.submittedKeysFileURL = submittedKeysFileURL
    }

    // MARK: Properties
    private let submittedKeysFileURL: URL
    
    private var submittedKeys = [ENTemporaryExposureKey]() {
        didSet {
            log(message: "Writing \(submittedKeys.count) keys)")
            let file = File.with { file in
                file.key = submittedKeys.map { diagnosisKey in
                    Key.with { key in
                        key.keyData = diagnosisKey.keyData
                        key.rollingPeriod = diagnosisKey.rollingPeriod
                        key.rollingStartNumber = diagnosisKey.rollingStartNumber
                        key.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
                    }
                }
            }
            // swiftlint:disable force_try
            let data = try! file.serializedData()
            // swiftlint:disable force_try
            try! data.write(to: submittedKeysFileURL)
            log(message: "Wrote \(submittedKeys.count) keys to \(submittedKeysFileURL)")
        }
    }

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
        let exposureConfiguration = ENExposureConfiguration()
        exposureConfiguration.minimumRiskScore = 0
        exposureConfiguration.attenuationWeight = 50
        exposureConfiguration.attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.attenuationWeight = 50
        exposureConfiguration.daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.daysSinceLastExposureWeight = 50
        exposureConfiguration.durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.durationWeight = 50
        exposureConfiguration.transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        exposureConfiguration.transmissionRiskWeight = 50

        completion(.success(exposureConfiguration))
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        submittedKeys += keys
        completion(/* error */ nil)
    }

    func fetch(completion: @escaping FetchKeysCompletionHandler) {
        completion(.success([submittedKeysFileURL]))
    }
}
