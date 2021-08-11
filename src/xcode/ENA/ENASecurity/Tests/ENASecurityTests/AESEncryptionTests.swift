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
}
