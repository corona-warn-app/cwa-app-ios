////
////  MockClient.swift
////  ENA
////
////  Created by Kienle, Christian on 08.05.20.
////  Copyright © 2020 SAP SE. All rights reserved.
////
//
//import Foundation
//import ExposureNotification
//
//extension ENExposureConfiguration {
//    // TODO: Make private once backend is fixed
//    class func mock() -> ENExposureConfiguration {
//        let config = ENExposureConfiguration()
//        config.minimumRiskScore = 0
//        config.attenuationWeight = 50
//        config.attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
//        config.daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
//        config.daysSinceLastExposureWeight = 50
//        config.durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
//        config.durationWeight = 50
//        config.transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
//        config.transmissionRiskWeight = 50
//        return config
//    }
//}
//
//final class MockClient: Client {
//    func fetchDay(_ day: String, completion completeWith: @escaping DayCompletionHandler) {
//        let bucket = Sap_FileBucket.with {
//            $0.files = [
//                Sap_File.with {
//                    $0.keys = submittedKeys.map { $0.sapKey }
//                }
//            ]
//        }
//        let signedPayload = Sap_SignedPayload.with {
//            // swiftlint:disable:next force_try
//            $0.payload = try! bucket.serializedData()
//        }
//
//        // swiftlint:disable:next force_try
//        let result = try! SAPKeyPackage(verifiedPayload: VerifiedPayload(signedPayload: signedPayload))
//        completeWith(.success(result))
//    }
//
//    func fetchHour(
//        _ hour: Int,
//        day: String,
//        completion completeWith: @escaping HourCompletionHandler
//    ) {
//        let bucket = Sap_FileBucket.with {
//            $0.files = [
//                Sap_File()
//            ]
//        }
//        let signedPayload = Sap_SignedPayload.with {
//            // swiftlint:disable:next force_try
//            $0.payload = try! bucket.serializedData()
//        }
//        // swiftlint:disable:next force_try
//        let result = try! SAPKeyPackage(verifiedPayload: VerifiedPayload(signedPayload: signedPayload))
//
//        completeWith(.success(result))
//    }
//
//    func availableDays(
//        completion completeWith: @escaping AvailableDaysCompletionHandler
//    ) {
//        completeWith(.success([.formattedToday()]))
//    }
//
//    func availableHours(
//        day: String,
//        completion completeWith: @escaping AvailableHoursCompletionHandler
//    ) {
//        completeWith(.success([]))
//    }
//
//    // MARK: Creating a Mock Client
//    init() {
//        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        self.submittedKeysFileURL = documentDir.appendingPathComponent("keys", isDirectory: false).appendingPathExtension("proto")
//    }
//
//    // MARK: Properties
//    private let submittedKeysFileURL: URL
//    
//    private var submittedKeys = [ENTemporaryExposureKey]()
//
//    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
//        completion(.mock())
//    }
//
//    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
//        submittedKeys += keys
//        completion(/* error */ nil)
//    }
//}
