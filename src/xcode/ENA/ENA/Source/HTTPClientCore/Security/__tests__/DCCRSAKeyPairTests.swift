////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DCCRSAKeyPairTests: CWATestCase {

	func testKeyPair() throws {
		let keyPair = try? DCCRSAKeyPair(registrationToken: "registrationToken")

		XCTAssertNotNil(keyPair)
		XCTAssertNotEqual(try keyPair?.privateKey(), try keyPair?.publicKey())
		XCTAssertEqual(try keyPair?.publicKeyForBackend().count, 564)

		// Key pair with same registration token retrieves keys from the keychain

		let keyPairDouble = try? DCCRSAKeyPair(registrationToken: "registrationToken")

		XCTAssertNotNil(keyPairDouble)
		XCTAssertEqual(try keyPairDouble?.privateKey(), try keyPair?.privateKey())
		XCTAssertEqual(try keyPairDouble?.publicKey(), try keyPair?.publicKey())
		XCTAssertEqual(try keyPairDouble?.publicKeyForBackend(), try keyPair?.publicKeyForBackend())

		// Removing from keychain

		keyPair?.removeFromKeychain()

		XCTAssertNotNil(keyPair)
		XCTAssertNil(try? keyPair?.privateKey())
		XCTAssertNil(try? keyPair?.publicKey())
		XCTAssertNil(try? keyPair?.publicKeyForBackend())

		// Create new key pair

		let newKeyPair = try? DCCRSAKeyPair(registrationToken: "registrationToken")

		XCTAssertNotNil(newKeyPair)
		XCTAssertNotEqual(try newKeyPair?.privateKey(), try newKeyPair?.publicKey())
		XCTAssertEqual(try newKeyPair?.publicKeyForBackend().count, 564)

		keyPair?.removeFromKeychain()
	}

	func testEncryptionDecryptionFlow() throws {
		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")

		// encryption
		let plainText = try XCTUnwrap("plain text".data(using: .utf8))
		let cipherText = try keyPair.encrypt(plainText)

		XCTAssertEqual(cipherText.count, SecKeyGetBlockSize(try keyPair.privateKey()))
		XCTAssertNotEqual(cipherText, plainText)

		// decryption
		let clearText = try keyPair.decrypt(cipherText)

		XCTAssertEqual(try XCTUnwrap(clearText), plainText)

		keyPair.removeFromKeychain()
	}

}
