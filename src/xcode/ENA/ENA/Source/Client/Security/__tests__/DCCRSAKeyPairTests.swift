////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DCCRSAKeyPairTests: CWATestCase {

	func testKeyPair() {
		let keyPair = try? DCCRSAKeyPair()

		XCTAssertNotNil(keyPair)
		XCTAssertNotEqual(keyPair?.privateKey, keyPair?.publicKey)
		XCTAssertEqual(keyPair?.publicKeyForBackend.count, 564)
	}

    func testGenerationEncodingAndDecoding() throws {
		do {
			let keyPair = try DCCRSAKeyPair()

			let encodedKeyPair = try JSONEncoder().encode(keyPair)
			let decodedKeyPair = try JSONDecoder().decode(DCCRSAKeyPair.self, from: encodedKeyPair)

			XCTAssertEqual(decodedKeyPair, keyPair)
		} catch {
			XCTFail("Key pair generation/encoding/decoding failed with error: \(error)")
		}
    }

}
