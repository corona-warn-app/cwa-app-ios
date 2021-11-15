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
        guard let privateKey = generationOutput.0,
              let publicKey = generationClass.generatePublicKey(from: privateKey) else {
                  XCTFail()
                  return
              }
        
        guard let publicKeyData = generationClass.generateData(from: publicKey).0 else {
            XCTFail()
            return
        }
        let bas64String = publicKeyData.base64EncodedString()
        let expectedHeaderString = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE"
        
        XCTAssertEqual(publicKeyData.bytes.count, 91)
        XCTAssertEqual(bas64String.count, 124)
        XCTAssertEqual(String(bas64String.prefix(36)), expectedHeaderString)
    }
}
