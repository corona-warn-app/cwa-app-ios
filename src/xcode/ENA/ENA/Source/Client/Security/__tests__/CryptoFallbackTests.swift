////
// 🦠 Corona-Warn-App
//

import XCTest
import CryptoKit
@testable import ENA


@available(iOS 13.0, *)
class CryptoFallbackTests: XCTestCase {

	// MARK: - SHA256 checks

    func testCustomSha256() throws {
		let data = try XCTUnwrap("Alice".data(using: .utf8))

		let customDigest = data.sha256(enforceFallback: true)
		let referenceDigest = Data(SHA256.hash(data: data))

		XCTAssertEqual(customDigest, referenceDigest)
    }

    func testPerformanceCryptoKitSHA256() throws {
        self.measure {
			for i in 0..<500_000 {
				// swiftlint:disable:next force_unwrapping
				let data = "Alice\(i)".data(using: .utf8)!
				_ = Data(SHA256.hash(data: data))
			}
        }
    }

	func testPerformanceFallbackSHA256() throws {
		self.measure {
			for i in 0..<500_000 {
				// swiftlint:disable:next force_unwrapping
				let data = "Alice\(i)".data(using: .utf8)!
				_ = data.sha256(enforceFallback: true)
			}
		}
	}

	// MARK: - Signature checks

	func testSignature() throws {
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)

		// CryptoKit 'base line'
		let signingKey = P256.Signing.PrivateKey()
		let ckSig = try signingKey.signature(for: data) as P256.Signing.ECDSASignature
		XCTAssertTrue(signingKey.publicKey.isValidSignature(ckSig, for: data))

		// custom implementation
		let pub = PublicKey(rawRepresentation: signingKey.publicKey.rawRepresentation)
		let sig = try signingKey.signature(for: data)
		XCTAssertTrue(pub.isValid_fallback(signature: sig, for: data))
	}

	func testSecKeyConversionRoundTrip() throws {
		// Private/Public key makes no difference. We use a public key in the 'real' conversion, so let's do this here as well
		let rootKey = P256.Signing.PrivateKey()
		let referenceKey = rootKey.publicKey
		let fallbackKey = CryptoProvider().createPublicKey(from: rootKey, useFallback: true)

		// ensure we use the correct types
		XCTAssertTrue(type(of: referenceKey) == P256.Signing.PublicKey.self)
		XCTAssertTrue(type(of: fallbackKey) == PublicKey.self)

		// should match
		XCTAssertEqual(
			referenceKey.x963Representation.base64EncodedString(),
			fallbackKey.x963Representation.base64EncodedString()
		)

		// convert key to `SecKey` for non CryptoKit processing, i.e. iOS <13.0
		let secKey = try XCTUnwrap(PublicKey.decodeSecKeyFromBase64(encodedKey: referenceKey.x963Representation.base64EncodedString()))
		let fallbackSecKey = try XCTUnwrap(PublicKey.decodeSecKeyFromBase64(encodedKey: fallbackKey.x963Representation.base64EncodedString()))

		// ok, now back to start to see if the generated _secKey_ is something valid
		let pub = SecKeyCopyExternalRepresentation(secKey, nil)
		let pubData = try XCTUnwrap(pub as Data?)
		XCTAssertEqual(referenceKey.x963Representation.base64EncodedString(), pubData.base64EncodedString())

		// ... and for the fallback key
		let fallbackPub = SecKeyCopyExternalRepresentation(fallbackSecKey, nil)
		let fallbackPubData = try XCTUnwrap(fallbackPub as Data?)
		XCTAssertEqual(fallbackKey.x963Representation.base64EncodedString(), fallbackPubData.base64EncodedString())

		// .. finally compare both SecKeys
		XCTAssertEqual(secKey, fallbackSecKey)
	}
}
