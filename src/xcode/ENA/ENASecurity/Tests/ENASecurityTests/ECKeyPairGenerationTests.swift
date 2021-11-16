//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import CryptoSwift
@testable import ENASecurity

final class ECKeyPairGenerationTests: XCTestCase {
    
    func test_validPublicKeyBase64_isGenerated() {
        let generationClass = ECKeyPairGeneration()
        let generationOutput = generationClass.generatePrivateKey(with: "test")
        
        guard let privateKey = generationOutput.0 else {
            XCTFail("Error while generating private EC key: \(generationOutput.1)")
            return
        }
        guard let publicKey = generationClass.generatePublicKey(from: privateKey) else {
            XCTFail("Error while generating Public EC key")
            return
        }
        let generatedDataFromKey = generationClass.generateData(from: publicKey)
        guard let publicKeyData = generatedDataFromKey.0 else {
            XCTFail("Error Converting the SecKey to CFData \(generatedDataFromKey.1)")
            return
        }
        let bas64String = publicKeyData.base64EncodedString()
        let expectedHeaderString = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE"
        
        XCTAssertEqual(publicKeyData.bytes.count, 91)
        XCTAssertEqual(bas64String.count, 124)
        XCTAssertEqual(String(bas64String.prefix(36)), expectedHeaderString)
    }
}
