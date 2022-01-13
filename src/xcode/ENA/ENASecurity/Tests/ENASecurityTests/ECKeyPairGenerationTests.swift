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
        let generationOutputResult = generationClass.generateECPair()
        
        switch generationOutputResult {
        case .success(let ecKeyPair):
            let expectedHeaderString = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE"
            XCTAssertEqual(ecKeyPair.publicKeyData.bytes.count, 91, "number of publicKeyDataBytes should be 91")
            XCTAssertEqual(ecKeyPair.publicKeyBase64.count, 124, "length of publicKeyBase64String should be 124")
            XCTAssertEqual(String(ecKeyPair.publicKeyBase64.prefix(36)), expectedHeaderString, "the first 36 characters should match the expected padding string")

        case .failure(let error):
            switch error {
            case .privateKeyGenerationError(let localizedErrorMessage):
                XCTFail("Error while generating private EC key: \(String(describing: localizedErrorMessage))")

            case .publicKeyGenerationFailed:
                XCTFail("Error while generating Public EC key")

            case .dataGenerationFromKeyFailed(let localizedErrorMessage):
                XCTFail("Error Converting the SecKey to CFData \(String(describing: localizedErrorMessage))")

            }
        }
    }
}
