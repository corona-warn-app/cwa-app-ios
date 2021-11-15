//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENASecurity

final class ECSHA256SignerTests: XCTestCase {
    
    func testGIVEN_SampleData1_WHEN_Signing_THEN_SampleDataMatches() throws {
        ///https://github.com/corona-warn-app/cwa-app-tech-spec/blob/ed371224ff6dbbd1968083f08babfcb7c06396a2/docs/spec/dcc-validation-service.md#sample-data-for-signing-data-with-sha256-and-an-ec-private-key
        // GIVEN
        let privateKeyBase64 = "MHcCAQEEIIIihYR7g405IESCjzqoUBTVi10rw+KoI4GA40QOrGCroAoGCCqGSM49AwEHoUQDQgAEqrIRZyw2XD7RhUAMXn/2gm9S1Z8BFrQd+peTEixW+jT3gzErD9a7hyZQXHHspqgwwmgUY6VX4NxR1puM43FTPQ=="
        let publicKeyBase64 = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEqrIRZyw2XD7RhUAMXn/2gm9S1Z8BFrQd+peTEixW+jT3gzErD9a7hyZQXHHspqgwwmgUY6VX4NxR1puM43FTPQ=="
        let dataBase64 = "SGVsbG8gV29ybGQh"
        let expectedSignatureBase64 = "MEUCICVeahDEVuULjkYuQDYeSAz/hMQL4kBGry5WwIzKTbHPAiEAuJHGGOPcjZAdvoXLkCdwXP7Bi8jvG7YUF1Nzaz8L/48="
        
        guard let publicKeyData = Data(base64Encoded: publicKeyBase64),
              let privateKeyData = Data(base64Encoded: privateKeyBase64),
              let expectedSignatureData = Data(base64Encoded: expectedSignatureBase64),
              let data = Data(base64Encoded: dataBase64)
        else {
            XCTFail("Could not convert Sampledata to Data")
            return
        }
        
        guard let privateKey = SecKey.privateEC(from: privateKeyData as CFData),
              let publicKey = SecKey.publicEC(from: publicKeyData as CFData) else {
                  XCTFail("Could not create SecKeys from Data")
                  return
              }
        
        // WHEN
        let signer = ECSHA256Signer(privateKey: privateKey, data: data)
        
        // Verify expectedSignature for publicKey and data
        let expectedSignatureDataSignatureVerficiation = SecKeyVerifySignature(publicKey, signer.algorithm, data as CFData, expectedSignatureData as CFData, nil)
        guard case .success(let signatureUnderTest) = signer.sign() else {
            XCTFail("Success was expected but something else happened.")
            return
        }
        
        var error: Unmanaged<CFError>?
        let signatureUnderTestDataSignatureVerficiation = SecKeyVerifySignature(publicKey, signer.algorithm, data as CFData, signatureUnderTest as CFData, &error)
        
        
        // THEN
        XCTAssertTrue(expectedSignatureDataSignatureVerficiation, "Failed to verify verification")
        XCTAssertTrue(signatureUnderTestDataSignatureVerficiation, "SignatureUnderTest failed to verifiy \(String(describing: error))")
        
    }
    
    func testGIVEN_SampleData2_WHEN_Signing_THEN_SampleDataMatches() throws {
        ///https://github.com/corona-warn-app/cwa-app-tech-spec/blob/ed371224ff6dbbd1968083f08babfcb7c06396a2/docs/spec/dcc-validation-service.md#sample-data-for-signing-data-with-sha256-and-an-ec-private-key
        // GIVEN
        let privateKeyBase64 = "MHcCAQEEICCuN2u+TLlBc5RsPkDFM0pLyH3lmpIc6vGd94FaQq8RoAoGCCqGSM49AwEHoUQDQgAENfTfICbBzrLfgGI8PfhXk/eNVunsik+/X+/uFqnmb2ZqPtcyS4X6/7wXmjCvWtvUv+6DI/Ejtd3a+B7Lf8IpQA=="
        let publicKeyBase64 = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAENfTfICbBzrLfgGI8PfhXk/eNVunsik+/X+/uFqnmb2ZqPtcyS4X6/7wXmjCvWtvUv+6DI/Ejtd3a+B7Lf8IpQA=="
        let dataBase64 = "VGVjaFNwZWNzIGFyZSBncjgh"
        let expectedSignatureBase64 = "MEYCIQDeYX+jOqX8F6rBLO6fRtZvpbzEgJnnrQJDuSHahbOU9wIhAPCk//4z279Bd55azEo9xixUylIFdeSmPIHKY+Y5J1+e"
        
        guard let publicKeyData = Data(base64Encoded: publicKeyBase64),
              let privateKeyData = Data(base64Encoded: privateKeyBase64),
              let expectedSignatureData = Data(base64Encoded: expectedSignatureBase64),
              let data = Data(base64Encoded: dataBase64)
        else {
            XCTFail("Could not convert Sampledata to Data")
            return
        }
        
        guard let privateKey = SecKey.privateEC(from: privateKeyData as CFData),
              let publicKey = SecKey.publicEC(from: publicKeyData as CFData) else {
                  XCTFail("Could not create SecKeys from Data")
                  return
              }
        
        // WHEN
        let signer = ECSHA256Signer(privateKey: privateKey, data: data)
        
        // Verify expectedSignature for publicKey and data
        let expectedSignatureDataSignatureVerficiation = SecKeyVerifySignature(publicKey, signer.algorithm, data as CFData, expectedSignatureData as CFData, nil)
        guard case .success(let signatureUnderTest) = signer.sign() else {
            XCTFail("Success was expected but something else happened.")
            return
        }
        
        var error: Unmanaged<CFError>?
        let signatureUnderTestDataSignatureVerficiation = SecKeyVerifySignature(publicKey, signer.algorithm, data as CFData, signatureUnderTest as CFData, &error)
        
        
        // THEN
        XCTAssertTrue(expectedSignatureDataSignatureVerficiation, "Failed to verify verification")
        XCTAssertTrue(signatureUnderTestDataSignatureVerficiation, "SignatureUnderTest failed to verifiy \(String(describing: error))")
    }
    
    
    func testGIVEN_NonECKey_WHEN_Signing_THEN_EC_SIGN_INVALID_KEY() throws {
        // GIVEN
        var statusCode: OSStatus?
        var publicKey: SecKey?
        var privateKey: SecKey?
        
        
        let publicKeyAttr: [NSObject: NSObject] = [
            kSecAttrIsPermanent: false as NSObject,
            kSecAttrApplicationTag: "publicKeyTag" as NSObject,
            kSecClass: kSecClassKey,
            kSecReturnData: kCFBooleanTrue
        ]
        
        let privateKeyAttr: [NSObject: NSObject] = [
            kSecAttrIsPermanent: false as NSObject,
            kSecAttrApplicationTag: "privateKeyTag" as NSObject,
            kSecClass: kSecClassKey,
            kSecReturnData: kCFBooleanTrue
        ]
        
        var keyPairAttr = [NSObject: NSObject]()
        keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        keyPairAttr[kSecAttrKeySizeInBits] = 3072 as NSObject
        keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
        keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject
        
        statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
        
        guard statusCode == noErr,
              let privateKey = privateKey else {
                  XCTFail("Failed to generate Keypair")
                  return
              }
        
        let data = Data()
        
        // WHEN
        let signer = ECSHA256Signer(privateKey: privateKey, data: data)
        
        // THEN
        guard case .failure(let error) = signer.sign() else {
            XCTFail("Success was expected but something else happened.")
            return
        }
        
        guard case .EC_SIGN_NOT_SUPPORTED = error else {
            XCTFail("Wrong error returned")
            return
        }
    }
}
