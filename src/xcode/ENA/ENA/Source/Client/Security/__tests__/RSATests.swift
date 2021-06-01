//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RSATests: XCTestCase {

	func testEncryptionDecryptionFlow() throws {
		let alice = try DGCRSAKeypair()
		let bob = try DGCRSAKeypair()

		let plainText = try XCTUnwrap("plain text".data(using: .utf8))
		let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256

		var error: Unmanaged<CFError>?
		guard let cipherText = SecKeyCreateEncryptedData(
				bob.publicKey,
				algorithm,
				plainText as CFData,
				&error) as Data?
		else {
			// swiftlint:disable:next force_unwrapping
			throw error!.takeRetainedValue() as Error
		}
		XCTAssertEqual(cipherText.count, SecKeyGetBlockSize(alice.privateKey))
		XCTAssertNotEqual(cipherText, plainText)

		// decryption
		guard let clearText = SecKeyCreateDecryptedData(
				bob.privateKey,
				algorithm,
				cipherText as CFData,
				&error) as Data?
		else {
			// swiftlint:disable:next force_unwrapping
			throw error!.takeRetainedValue() as Error
		}
		XCTAssertEqual(clearText, plainText)
	}

}
