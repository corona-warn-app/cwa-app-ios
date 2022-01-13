//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class RSAEncryptionTests: XCTestCase {

    func testGIVEN_RASKeysAndBase64TextHelloWorld_WHEN_EncryptAndDecrype_THEN_TextIsSameAsGiven() throws {

        // GIVEN

        let publicKeyBase64 = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDKzLd2S1DD9aXUI90ns1Eq+3t/I9IPbMY0IJGDFNqsSCvVJc5sag5tGLP+hVdeIsKpprKCEQI0QwEp+N8DBQoMRL/oib44J8Fs7UB2gcTAdphmVDLLxhr40CcHLAnHvu5kH4Jf/HMGoh1pT4PgUR54Vcb5fZ70LR/2EN9ckAoDgwIDAQAB"
        let privateKeyBase64 = "MIICXAIBAAKBgQDKzLd2S1DD9aXUI90ns1Eq+3t/I9IPbMY0IJGDFNqsSCvVJc5sag5tGLP+hVdeIsKpprKCEQI0QwEp+N8DBQoMRL/oib44J8Fs7UB2gcTAdphmVDLLxhr40CcHLAnHvu5kH4Jf/HMGoh1pT4PgUR54Vcb5fZ70LR/2EN9ckAoDgwIDAQABAoGABudXK4C+3Bzlq0YZRju1fKgY+SgIA5xpVubw7SxtkUXXsCbcUxZ9LTuVDQoPAlZemBXjp8faclsBlCMzvE+UmuzGtsvRGmSU58DX5/bgrclTticzTgHhCWqt5MsOVcyEMJq7kQQxWSnuLGOnUcTaBNKqw5BFm+qETtcVFNDtl4kCQQDw2A/AiSQbslbO3x2qRxInCgHYUPd42wwxz4zmT4RKbYEHhWBxBGntBEye5oiLfwCAitkdDPiqtQiTCAe+HW93AkEA14/FN9WzH01a/t0uS6fU3XDY9kOvN6wYtr9E68BcmgblveR4oU6Oj8RHDSJJLfO6xC9c9ZtBYDKLzBuApvZHVQJBAMc30X/PcODAGfIwuFcbRraoHnKSNsHvXxzss33mlGUEQ1C3UNjrb7swbTibNKM+wGmTcJgJHMAH0znb0Ju/uW0CQAij/7DMRSDVFfevYAKyWIsD0f6VGfnuURNKOXYFwPB/pEfnV5qHrpk+seZp4GsSIQNqLpy9u3IitI3a8F5A8v0CQGIgBA87TcMe3iYqFVirXM+7DZcuv49UVeNxMSZ0SlRFDl7t/HxLBF6n0N9OzqzvUDgDJQSq+mEj+QZ8LIiL9yQ="

        guard let publicKeyData = Data(base64Encoded: publicKeyBase64),
              let privateKeyData = Data(base64Encoded: privateKeyBase64),
              let plainText = Data(base64Encoded: "SGVsbG8gV29ybGQh")
        else {
            XCTFail("Could not create test data public key")
            return
        }

        let publicKey = try XCTUnwrap(
            SecKeyCreateWithData(
                publicKeyData as NSData,
                [
                    kSecAttrKeyType: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass: kSecAttrKeyClassPublic,
                ] as NSDictionary,
                nil
            )
        )

        let privateKey = try XCTUnwrap(
            SecKeyCreateWithData(
                privateKeyData as NSData,
                [
                    kSecAttrKeyType: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                ] as NSDictionary,
                nil
            )
        )

        let rsaEncryption = RSAEncryption()

        // WHEN
        let encryptedResult = rsaEncryption.encrypt(plainText, publicKey: publicKey)
        guard case let .success(encryptedData) = encryptedResult else {
            XCTFail("Failed to encrypt data")
            return
        }

        let decryptResult = rsaEncryption.decrypt(data: encryptedData, privateKey: privateKey)
        guard case let .success(decryptedData) = decryptResult else {
            XCTFail("Failed to encrypt data")
            return
        }

        let string = try XCTUnwrap(decryptedData.base64EncodedString())
        let helloWorld = String(data: decryptedData, encoding: .utf8)

        // THEN
        XCTAssertEqual("SGVsbG8gV29ybGQh", string)
        XCTAssertEqual("Hello World!", helloWorld)
    }

    func testGIVEN_Base64Cipher_WHEN_Decrypt_THEN_TextIsCoronaWarnApp() throws {

        // GIVEN
        let privateKeyBase64 = "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"
        let base64Cipher = "TH6SIRXRYCheQbGDdcIcU8noeU5svI8pXWN8iCfNp7VeC0OAtDSz97KVNHzaU7v3rLY5trT0Ac3T32MZotwOw7Iu33rvwQcdDM3ePIxQ86fSw/aZ80UMc3v56CdmFMTI3deHqPHTWbUtNdQAtse2tGA2yJtkUZtZ4O3t43kX1GW4JWbQeLr5cuq5NOcmbH+RCHQMM0GlJlFD/1MfACxQfyYg7axut4fx990MDpAIzIFWB5UqZPya+Y95xNUWLfjaue0ANjORlIkq2ct5leFt8j89z8AcnYKGomTmu//hxpwpYrDWOLHKxeK4RoXL9IU1YkWNoghiBqhX/XBzlf4S6NJSUUm2Er/fhO0yoKKO28F8qZZdzRAwBeUurF6uQ5QMvUIIoVaRP4l/2rYI4qe6jhXYmeej4pTGL9C1huRYNF2HE6ymMn2K0zGqq8YJhj5arfaw8+olwb0BXGU0Su9Qpv6koRaZYbF91Z14W0tOu/ZbOIjn7vsbt2B0r1Y5fC/l"

        guard let privateKeyData = Data(base64Encoded: privateKeyBase64)
        else {
            XCTFail("Could not create test data public key")
            return
        }

        let privateKey = try XCTUnwrap(
            SecKeyCreateWithData(
                privateKeyData as NSData,
                [
                    kSecAttrKeyType: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                ] as NSDictionary,
                nil
            )
        )
        
        let rsaEncryption = RSAEncryption()

        // WHEN
        let encryptedData = try XCTUnwrap(Data(base64Encoded: base64Cipher))
        let decryptResult = rsaEncryption.decrypt(data: encryptedData, privateKey: privateKey)
        guard case let .success(decryptedData) = decryptResult else {
            XCTFail("Failed to encrypt data")
            return
        }

        let string = try XCTUnwrap(decryptedData.base64EncodedString())
        let decodedString = String(data: decryptedData, encoding: .utf8)

        // THEN
        XCTAssertEqual("Q29yb25hLVdhcm4tQXBw", string)
        XCTAssertEqual("Corona-Warn-App", decodedString)
    }

}
