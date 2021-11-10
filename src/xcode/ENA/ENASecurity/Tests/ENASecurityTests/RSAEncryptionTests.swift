//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class RSAEncryptionTests: XCTestCase {

    func test_When_Decrypt_Then_CorrectStringIsReturned() throws {
        let publicKeyBase64 = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDKzLd2S1DD9aXUI90ns1Eq+3t/I9IPbMY0IJGDFNqsSCvVJc5sag5tGLP+hVdeIsKpprKCEQI0QwEp+N8DBQoMRL/oib44J8Fs7UB2gcTAdphmVDLLxhr40CcHLAnHvu5kH4Jf/HMGoh1pT4PgUR54Vcb5fZ70LR/2EN9ckAoDgwIDAQAB"
        let privateKeyBase64 = "MIICXAIBAAKBgQDKzLd2S1DD9aXUI90ns1Eq+3t/I9IPbMY0IJGDFNqsSCvVJc5sag5tGLP+hVdeIsKpprKCEQI0QwEp+N8DBQoMRL/oib44J8Fs7UB2gcTAdphmVDLLxhr40CcHLAnHvu5kH4Jf/HMGoh1pT4PgUR54Vcb5fZ70LR/2EN9ckAoDgwIDAQABAoGABudXK4C+3Bzlq0YZRju1fKgY+SgIA5xpVubw7SxtkUXXsCbcUxZ9LTuVDQoPAlZemBXjp8faclsBlCMzvE+UmuzGtsvRGmSU58DX5/bgrclTticzTgHhCWqt5MsOVcyEMJq7kQQxWSnuLGOnUcTaBNKqw5BFm+qETtcVFNDtl4kCQQDw2A/AiSQbslbO3x2qRxInCgHYUPd42wwxz4zmT4RKbYEHhWBxBGntBEye5oiLfwCAitkdDPiqtQiTCAe+HW93AkEA14/FN9WzH01a/t0uS6fU3XDY9kOvN6wYtr9E68BcmgblveR4oU6Oj8RHDSJJLfO6xC9c9ZtBYDKLzBuApvZHVQJBAMc30X/PcODAGfIwuFcbRraoHnKSNsHvXxzss33mlGUEQ1C3UNjrb7swbTibNKM+wGmTcJgJHMAH0znb0Ju/uW0CQAij/7DMRSDVFfevYAKyWIsD0f6VGfnuURNKOXYFwPB/pEfnV5qHrpk+seZp4GsSIQNqLpy9u3IitI3a8F5A8v0CQGIgBA87TcMe3iYqFVirXM+7DZcuv49UVeNxMSZ0SlRFDl7t/HxLBF6n0N9OzqzvUDgDJQSq+mEj+QZ8LIiL9yQ="

        guard let publicKeyData = Data(base64Encoded: publicKeyBase64),
              let privateKeyData = Data(base64Encoded: privateKeyBase64),
              let publicKey = SecKeyCreateWithData(publicKeyData as NSData, [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
              ] as NSDictionary, nil),
              let privateKey = SecKeyCreateWithData(privateKeyData as NSData, [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
              ] as NSDictionary, nil),
              let plainText = Data(base64Encoded: "SGVsbG8gV29ybGQh")
        else {
            XCTFail("Could not create test data public key")
            return
        }

        let rsaEncryption = RSAEncryption(publicKey)
        let encryptedResult = rsaEncryption.encrypt(plainText)

        guard case let .success(encryptedData) = encryptedResult else {
            XCTFail("Failed to encrypt data")
            return
        }

        let decryptResult = rsaEncryption.decrypt(privateKey: privateKey, cipherData: encryptedData)
        guard case let .success(decryptedData) = decryptResult else {
            XCTFail("Failed to encrypt data")
            return
        }

        let string = try XCTUnwrap(decryptedData.base64EncodedString())
        let helloWorld = String(data: decryptedData, encoding: .utf8)
        XCTAssertEqual("SGVsbG8gV29ybGQh", string)
        XCTAssertEqual("Hello World!", helloWorld)
    }
}
