//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class CBCEncryptionTests: XCTestCase {

    func test_When_Decrypt_Then_CorrectStringIsReturned() {
        guard let key = Data(base64Encoded: "d56t/juMw5r4qNx1n1igs1pobUjZBT5yq0Ct7MHUuKM="),
              let encrypted = Data(base64Encoded: "WFOLewp8DWqY/8IWUHEDwg==") else {
            XCTFail("Could not create test data.")
            return
        }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: AESEncryptionConstants.zeroInitializationVector
        )
        let result = cbcEncryption.decrypt(data: encrypted)

        guard case let .success(decryptedData) = result else {
            XCTFail("Success expected.")
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

            let cbcEncryption = CBCEncryption(
                encryptionKey: key,
                initializationVector: vector
            )
            let result = cbcEncryption.decrypt(data: encrypted)

            guard case let .success(decryptedData) = result else {
                XCTFail("Success expected.")
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

            let cbcEncryption = CBCEncryption(
                encryptionKey: key,
                initializationVector: vector
            )
            let result = cbcEncryption.encrypt(data: decrypted)

            guard case let .success(encryptedData) = result else {
                XCTFail("Success expected.")
                return
            }

            XCTAssertEqual(testData.expectedCiphertextBase64, encryptedData.base64EncodedString())
        }
    }

    func test_When_Encrypt_Then_Error_AES_GCM_INVALID_KEY() {
        let testData = testDatas[0]

        // Empty key is an invalid key.
        // Encryption should return error .AES_GCM_INVALID_KEY with this key.
        let key = Data()

        guard let decrypted = Data(base64Encoded: testData.plaintextBase64),
              let initializationVector = Data(base64Encoded: testData.ivBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector
        )

        let result = cbcEncryption.encrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_KEY = error else {
                  XCTFail("Failure expected.")
                  return
              }
    }

    func test_When_Decrypt_Then_Error_AES_GCM_INVALID_KEY() {
        let testData = testDatas[0]

        // Empty key is an invalid key.
        // Encryption should return error .AES_GCM_INVALID_KEY with this key.
        let key = Data()

        guard let decrypted = Data(base64Encoded: testData.plaintextBase64),
              let initializationVector = Data(base64Encoded: testData.ivBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector
        )

        let result = cbcEncryption.decrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_KEY = error else {
                  XCTFail("Failure expected.")
                  return
              }
    }

    func test_When_Encrypt_Then_Error_AES_CBC_INVALID_IV() {
        let testData = testDatas[0]

        // Empty initializationVector is an invalid initialization vector.
        // Encryption should return error .AES_GCM_INVALID_IV with this initialization vector.
        let initializationVector = Data(capacity: 0)

        print("initializationVector.isEmpty: \(initializationVector.isEmpty)")

        guard let key = Data(base64Encoded: testData.keyBase64),
            let decrypted = Data(base64Encoded: testData.plaintextBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector
        )

        let result = cbcEncryption.encrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_IV = error else {
                  XCTFail("Failure expected.")
                  return
              }
    }

    func test_When_Decrypt_Then_Error_AES_CBC_INVALID_IV() {
        let testData = testDatas[0]

        // Empty initializationVector is an invalid initialization vector.
        // Encryption should return error .AES_GCM_INVALID_IV with this initialization vector.
        let initializationVector = Data(capacity: 0)

        print("initializationVector.isEmpty: \(initializationVector.isEmpty)")

        guard let key = Data(base64Encoded: testData.keyBase64),
            let decrypted = Data(base64Encoded: testData.plaintextBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector
        )

        let result = cbcEncryption.decrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_IV = error else {
                  XCTFail("Failure expected.")
                  return
              }
    }

    func test_When_Encrypt_With_ivLengthConstraint_Then_Error_AES_CBC_INVALID_IV() {
        let testData = testDatas[0]

        // initializationVector of size 13 should return an error with ivLengthConstraint of 16
        let initializationVector = Data(capacity: 13)

        print("initializationVector.isEmpty: \(initializationVector.isEmpty)")

        guard let key = Data(base64Encoded: testData.keyBase64),
            let decrypted = Data(base64Encoded: testData.plaintextBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector,
            ivLengthConstraint: 16
        )

        let result = cbcEncryption.encrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_IV = error else {
                  XCTFail("Failure expected.")
                  return
              }
    }

    func test_When_Decrypt_With_ivLengthConstraint_Then_Error_AES_CBC_INVALID_IV() {
        let testData = testDatas[0]

        // initializationVector of size 13 should return an error with ivLengthConstraint of 16
        let initializationVector = Data(capacity: 13)

        print("initializationVector.isEmpty: \(initializationVector.isEmpty)")

        guard let key = Data(base64Encoded: testData.keyBase64),
            let decrypted = Data(base64Encoded: testData.plaintextBase64) else {
                  XCTFail("Could not create test data.")
                  return
              }

        let cbcEncryption = CBCEncryption(
            encryptionKey: key,
            initializationVector: initializationVector,
            ivLengthConstraint: 16
        )

        let result = cbcEncryption.decrypt(data: decrypted)

        guard case .failure(let error) = result,
              case .AES_CBC_INVALID_IV = error else {
                  XCTFail("Failure expected.")
                  return
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
