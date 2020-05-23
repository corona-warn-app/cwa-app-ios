//
//  MockClient.swift
//  ENA
//
//  Created by Kienle, Christian on 08.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification
import CommonCrypto

final class MockClient: Client {
    static let privateKeyECData = Data(base64Encoded: """
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgKJNe9P8hzcbVkoOYM4hJFkLERNKvtC8B40Y/BNpfxMeh\
    RANCAASfuKEs4Z9gHY23AtuMv1PvDcp4Uiz6lTbA/p77if0yO2nXBL7th8TUbdHOsUridfBZ09JqNQYKtaU9BalkyodM
    """)!

    func fetchDay(_ day: String, completion completeWith: @escaping DayCompletionHandler) {
        do {
            let attributes = [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits: 256
                ] as CFDictionary

            var cfError: Unmanaged<CFError>?

            let privateKeyData = MockClient.privateKeyECData.suffix(65) + MockClient.privateKeyECData.subdata(in: 36..<68)
            guard let secKey = SecKeyCreateWithData(privateKeyData as CFData, attributes, &cfError) else {
                fatalError("should never happen")
            }

            let signatureInfo = Apple_SignatureInfo.with { signatureInfo in
                // swiftlint:disable:next force_unwrapping
                signatureInfo.appBundleID = Bundle.main.bundleIdentifier!
                signatureInfo.verificationKeyVersion = "v1"
                signatureInfo.verificationKeyID = "310"
                signatureInfo.signatureAlgorithm = "SHA256withECDSA"
            }

            let export = Apple_TemporaryExposureKeyExport.with {
                $0.batchNum = 1
                $0.batchSize = 1
                $0.region = "DE"
                $0.signatureInfos = [signatureInfo]
                $0.keys = submittedKeys.shuffled().map { diagnosisKey in
                    Apple_TemporaryExposureKey.with { temporaryExposureKey in
                        temporaryExposureKey.keyData = diagnosisKey.keyData
                        temporaryExposureKey.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
                        temporaryExposureKey.rollingStartIntervalNumber = Int32(diagnosisKey.rollingStartNumber)
                        temporaryExposureKey.rollingPeriod = Int32(diagnosisKey.rollingPeriod)
                    }
                }
            }

            // swiftlint:disable:next force_unwrapping
            let exportData = "EK Export v1    ".data(using: .utf8)! + (try export.serializedData())

            var exportHash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = exportData.withUnsafeBytes { exportDataBuffer in
                exportHash.withUnsafeMutableBytes { exportHashBuffer in
                    CC_SHA256(exportDataBuffer.baseAddress, CC_LONG(exportDataBuffer.count), exportHashBuffer.bindMemory(to: UInt8.self).baseAddress)
                }
            }


            guard let signedHash = SecKeyCreateSignature(secKey, .ecdsaSignatureDigestX962SHA256, exportHash as CFData, &cfError) as Data? else {
                fatalError("should never happen")
            }


            let tekSignatureList = Apple_TEKSignatureList.with { tekSignatureList in
                tekSignatureList.signatures = [
                    Apple_TEKSignature.with { tekSignature in
                        tekSignature.signatureInfo = signatureInfo
                        tekSignature.signature = signedHash
                        tekSignature.batchNum = 1
                        tekSignature.batchSize = 1
                    }
                ]
            }
            let sigData = try tekSignatureList.serializedData()
            completeWith(.success(SAPKeyPackage(keysBin: exportData, signature: sigData)))
        } catch {
            logError(message: error.localizedDescription)
        }
    }

    func fetchHour(
        _ hour: Int,
        day: String,
        completion completeWith: @escaping HourCompletionHandler
    ) {
               do {
            let attributes = [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits: 256
                ] as CFDictionary

            var cfError: Unmanaged<CFError>?

            let privateKeyData = MockClient.privateKeyECData.suffix(65) + MockClient.privateKeyECData.subdata(in: 36..<68)
            guard let secKey = SecKeyCreateWithData(privateKeyData as CFData, attributes, &cfError) else {
                fatalError("should never happen")
            }

            let signatureInfo = Apple_SignatureInfo.with { signatureInfo in
                // swiftlint:disable:next force_unwrapping
                signatureInfo.appBundleID = Bundle.main.bundleIdentifier!
                signatureInfo.verificationKeyVersion = "v1"
                signatureInfo.verificationKeyID = "310"
                signatureInfo.signatureAlgorithm = "SHA256withECDSA"
            }

            let export = Apple_TemporaryExposureKeyExport.with {
                $0.batchNum = 1
                $0.batchSize = 1
                $0.region = "DE"
                $0.signatureInfos = [signatureInfo]
                $0.keys = submittedKeys.shuffled().map { diagnosisKey in
                    Apple_TemporaryExposureKey.with { temporaryExposureKey in
                        temporaryExposureKey.keyData = diagnosisKey.keyData
                        temporaryExposureKey.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
                        temporaryExposureKey.rollingStartIntervalNumber = Int32(diagnosisKey.rollingStartNumber)
                        temporaryExposureKey.rollingPeriod = Int32(diagnosisKey.rollingPeriod)
                    }
                }
            }

            // swiftlint:disable:next force_unwrapping
            let exportData = "EK Export v1    ".data(using: .utf8)! + (try export.serializedData())

            var exportHash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = exportData.withUnsafeBytes { exportDataBuffer in
                exportHash.withUnsafeMutableBytes { exportHashBuffer in
                    CC_SHA256(exportDataBuffer.baseAddress, CC_LONG(exportDataBuffer.count), exportHashBuffer.bindMemory(to: UInt8.self).baseAddress)
                }
            }


            guard let signedHash = SecKeyCreateSignature(secKey, .ecdsaSignatureDigestX962SHA256, exportHash as CFData, &cfError) as Data? else {
                fatalError("should never happen")
            }


            let tekSignatureList = Apple_TEKSignatureList.with { tekSignatureList in
                tekSignatureList.signatures = [
                    Apple_TEKSignature.with { tekSignature in
                        tekSignature.signatureInfo = signatureInfo
                        tekSignature.signature = signedHash
                        tekSignature.batchNum = 1
                        tekSignature.batchSize = 1
                    }
                ]
            }
            let sigData = try tekSignatureList.serializedData()
            completeWith(.success(SAPKeyPackage(keysBin: exportData, signature: sigData)))
        } catch {
            logError(message: error.localizedDescription)
        }
    }

    func availableDays(
        completion completeWith: @escaping AvailableDaysCompletionHandler
    ) {
        completeWith(.success([.formattedToday()]))
    }

    func availableHours(
        day: String,
        completion completeWith: @escaping AvailableHoursCompletionHandler
    ) {
        completeWith(.success([]))
    }

    // MARK: Creating a Mock Client
    init() {
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.submittedKeysFileURL = documentDir.appendingPathComponent("keys", isDirectory: false).appendingPathExtension("proto")
    }

    // MARK: Properties
    private let submittedKeysFileURL: URL

    private var submittedKeys = [ENTemporaryExposureKey]()

    func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
        completion(.mock())
    }

    func submit(keys: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
        submittedKeys += keys
        completion(/* error */ nil)
    }
}
