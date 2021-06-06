//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RSATests: XCTestCase {

	func testEncryptionDecryptionFlow() throws {
		let keys = try DGCRSAKeypair()

		let plainText = try XCTUnwrap("plain text".data(using: .utf8))
		let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256

		var error: Unmanaged<CFError>?
		guard let cipherText = SecKeyCreateEncryptedData(
				keys.publicKey,
				algorithm,
				plainText as CFData,
				&error) as Data?
		else {
			// swiftlint:disable:next force_unwrapping
			throw error!.takeRetainedValue() as Error
		}
		XCTAssertEqual(cipherText.count, SecKeyGetBlockSize(keys.privateKey))
		XCTAssertNotEqual(cipherText, plainText)

		// decryption
		let clearText = try keys.decrypt(message: cipherText)
		XCTAssertEqual(try XCTUnwrap(clearText), plainText)
	}

}
