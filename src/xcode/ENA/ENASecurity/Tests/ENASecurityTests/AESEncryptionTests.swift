//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class AESEncryptionTests: XCTestCase {

    func test_When_Decrypt_Then_CorrectStringIsReturned() {
        guard let key = Data(base64Encoded: "d56t/juMw5r4qNx1n1igs1pobUjZBT5yq0Ct7MHUuKM="),
              let encrypted = Data(base64Encoded: "WFOLewp8DWqY/8IWUHEDwg==") else {
            XCTFail("Could not create test data.")
            return
        }

        let aesEncryption = AESEncryption(
            encryptionKey: key,
            initializationVector: AESEncryptionConstants.zeroInitializationVector
        )
        let result = aesEncryption.decrypt(data: encrypted)

        guard case let .success(decryptedData) = result else {
            return
        }

        XCTAssertEqual("Hello World", String(data: decryptedData, encoding: .utf8))
    }

    func test_When_Encrypt_TestDatas_Then_CorrectStringIsReturned() {
        for testData in testDatas {
            guard let key = Data(base64Encoded: testData.keyBase64),
                  let encrypted = Data(base64Encoded: testData.expectedCiphertextBase64),
                  let vector = Data(base64Encoded: testData.ivBase64) else {
                XCTFail("Could not create test data.")
                return
            }

            let aesEncryption = AESEncryption(
                encryptionKey: key,
                initializationVector: vector
            )
            let result = aesEncryption.decrypt(data: encrypted)

            guard case let .success(decryptedData) = result else {
                return
            }

            XCTAssertEqual(testData.plaintextUtf8, String(data: decryptedData, encoding: .utf8))
        }
    }

    func test_When_Decrypt_TestDatas_Then_CorrectStringIsReturned() {
        for testData in testDatas {
            guard let key = Data(base64Encoded: testData.keyBase64),
                  let decrypted = Data(base64Encoded: testData.plaintextBase64),
                  let vector = Data(base64Encoded: testData.ivBase64) else {
                XCTFail("Could not create test data.")
                return
            }

            let aesEncryption = AESEncryption(
                encryptionKey: key,
                initializationVector: vector
            )
            let result = aesEncryption.encrypt(data: decrypted)

            guard case let .success(encryptedData) = result else {
                return
            }

            XCTAssertEqual(testData.expectedCiphertextBase64, encryptedData.base64EncodedString())
        }
    }

    private struct AESEncryptionTestData {
        let keyBase64: String
        let ivBase64: String
        let plaintextBase64: String
        let plaintextUtf8: String
        let expectedCiphertextBase64: String
    }

    private let testDatas = [
        AESEncryptionTestData(
            keyBase64: "i8XlNW0rYXMDVBBsL1x+ACmA7V+EVtS2/MGRwZsTylw=",
            ivBase64: "FWfVIhs9RGwDkqJiGsA71g==",
            plaintextBase64: "SGVsbG8gV29ybGQh",
            plaintextUtf8: "Hello World!",
            expectedCiphertextBase64: "dNAhkJey3d1IwO2+I9U6Ng=="
        ),
        AESEncryptionTestData(
            keyBase64: "bZNbuUL2P2nJ3Rmb8AOWKudjpvPxlPjSM13fJNQ22yg=",
            ivBase64: "2yo8Cw8MFM5xRne9bVClKg==",
            plaintextBase64: "VGVjaFNwZWNzIGFyZSBncjgh",
            plaintextUtf8: "TechSpecs are gr8!",
            expectedCiphertextBase64: "20ofpjSnTA/mkJwn8G7WvOH52cPbMtC7n8xHB7AYBzE="
        )
    ]
}
