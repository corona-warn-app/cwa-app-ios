////
// 🦠 Corona-Warn-App
//

import XCTest
#if canImport(CryptoKit)
import CryptoKit
#endif
@testable import ENA


@available(iOS 13.0, *)
class CryptoFallbackTests: iOS13TestCase {

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

	func testPrivateKeyGeneration() throws {
		let custom1 = CryptoProvider.createPrivateKey(useFallback: true)
		let custom2 = CryptoProvider.createPrivateKey(useFallback: false)

		// type check to ensure we really use the fallback
		XCTAssertTrue(type(of: custom1) == PrivateKey.self)
		XCTAssertTrue(type(of: custom2) == P256.Signing.PrivateKey.self)

		// assume equal size
		XCTAssertEqual(custom1.rawRepresentation.count, custom2.rawRepresentation.count)
		XCTAssertEqual(custom1.x963Representation.count, custom2.x963Representation.count)

		// check X9.63 representation
		XCTAssertEqual([UInt8](custom1.x963Representation).first, 0x04)
		XCTAssertEqual([UInt8](custom2.x963Representation).first, 0x04)
	}

	func testPublicKeyGeneration() throws {
		let rootKey = P256.Signing.PrivateKey()
		let referenceKey = rootKey.publicKey

		let fallbackKey1 = PublicKey(rawRepresentation: rootKey.publicKey.rawRepresentation)
		let fallbackKey2 = CryptoProvider.createPublicKey(from: rootKey, useFallback: true)

		// ensure we use the correct types
		XCTAssertTrue(type(of: referenceKey) == P256.Signing.PublicKey.self)
		XCTAssertTrue(type(of: fallbackKey1) == PublicKey.self)
		XCTAssertTrue(type(of: fallbackKey2) == PublicKey.self)

		// check X9.63 representation
		XCTAssertEqual([UInt8](referenceKey.x963Representation).first, 0x04)
		XCTAssertEqual([UInt8](fallbackKey1.x963Representation).first, 0x04)
		XCTAssertEqual([UInt8](fallbackKey2.x963Representation).first, 0x04)

		XCTAssertEqual(
			referenceKey.x963Representation.base64EncodedString(),
			fallbackKey1.x963Representation.base64EncodedString()
		)
		XCTAssertEqual(
			fallbackKey1.x963Representation.base64EncodedString(),
			fallbackKey2.x963Representation.base64EncodedString()
		)
	}

	func testSecKeyConversionRoundTrip() throws {
		// Private/Public key makes no difference. We use a public key in the 'real' conversion, so let's do this here as well
		let rootKey = P256.Signing.PrivateKey()
		let referenceKey = rootKey.publicKey
		let fallbackKey = CryptoProvider.createPublicKey(from: rootKey, useFallback: true)

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

	func testSignature() throws {
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 32) // [Int64]

		// test with CryptoKit as 'base line'
		let rootKey = P256.Signing.PrivateKey()
		let referenceKey = rootKey.publicKey
		// Fallback
		let fallbackPublicKey = try XCTUnwrap(CryptoProvider.createPublicKey(from: rootKey, useFallback: true) as? PublicKey)

		// just to be sure...
		XCTAssertTrue(type(of: rootKey) == P256.Signing.PrivateKey.self)
		XCTAssertTrue(type(of: referenceKey) == P256.Signing.PublicKey.self)
		XCTAssertTrue(type(of: fallbackPublicKey) == PublicKey.self)

		// should match
		XCTAssertEqual(
			referenceKey.x963Representation.base64EncodedString(),
			fallbackPublicKey.x963Representation.base64EncodedString()
		)

		// sign data and validate signature format
		let signature: P256.Signing.ECDSASignature = try rootKey.signature(for: data)
		XCTAssertTrue(type(of: signature) == P256.Signing.ECDSASignature.self)
		XCTAssertEqual(signature.rawRepresentation.count, 64) // as of https://tools.ietf.org/html/rfc4754#section-7

		// finally, signature validation
		XCTAssertTrue(referenceKey.isValidSignature(signature, for: data))
		XCTAssertTrue(referenceKey.isValid(signature: signature, for: data))
		XCTAssertTrue(fallbackPublicKey.isValid(signature: signature, for: data))
		XCTAssertTrue(fallbackPublicKey.isValid_fallback(signature: signature, for: data))
	}

	func testSignatureFallbackOnly() throws {
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 32) // [Int64]

		let rootKey = try PrivateKey()
		let publicKey = rootKey.publicKey

		// CryptoKit as reference (explicit casting)
		let referencePublicKey = try P256.Signing.PublicKey(x963Representation: publicKey.x963Representation)

		// just to be sure...
		XCTAssertTrue(type(of: rootKey) == PrivateKey.self)
		XCTAssertTrue(type(of: publicKey) == PublicKey.self)
		XCTAssertTrue(type(of: referencePublicKey) == P256.Signing.PublicKey.self)

		// should match
		XCTAssertEqual(
			publicKey.x963Representation.base64EncodedString(),
			referencePublicKey.x963Representation.base64EncodedString()
		)

		// sign data and validate signature format
		let signature = try rootKey.signature(for: data)
		XCTAssertGreaterThanOrEqual(signature.derRepresentation.count, 70)
		XCTAssertTrue(type(of: signature) == ECDSASignature.self)

		// finally, signature validation
		XCTAssertTrue(publicKey.isValid(signature: signature, for: data)) // uses CryptoKit
		XCTAssertTrue(publicKey.isValid_fallback(signature: signature, for: data)) // explicit fallback

		let refernceSignature = try P256.Signing.ECDSASignature(derRepresentation: signature.derRepresentation)
		XCTAssertTrue(publicKey.isValid(signature: refernceSignature, for: data)) // uses CryptoKit
		XCTAssertTrue(publicKey.isValid_fallback(signature: refernceSignature, for: data)) // explicit fallback
		XCTAssertTrue(referencePublicKey.isValidSignature(refernceSignature, for: data))
	}

	// MARK: - Bad data tests

	func testAlteredDataValidation() throws {
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD] as [UInt8], count: 4)

		let rootKey = try PrivateKey()
		let publicKey = rootKey.publicKey

		// CryptoKit as reference (explicit casting)
		let referencePublicKey = try P256.Signing.PublicKey(x963Representation: publicKey.x963Representation)

		// sign data and validate signature format
		let signature = try rootKey.signature(for: data)
		XCTAssertGreaterThanOrEqual(signature.derRepresentation.count, 70)
		XCTAssertTrue(type(of: signature) == ECDSASignature.self)

		// now alter the data
		let data2 = Data(bytes: [0xB, 0xB, 0xC, 0xD] as [UInt8], count: 4)

		// finally, signature validation
		XCTAssertFalse(publicKey.isValid(signature: signature, for: data2)) // uses CryptoKit
		XCTAssertFalse(publicKey.isValid_fallback(signature: signature, for: data2)) // explicit fallback

		let refernceSignature = try P256.Signing.ECDSASignature(derRepresentation: signature.derRepresentation)
		XCTAssertFalse(publicKey.isValid(signature: refernceSignature, for: data2)) // uses CryptoKit
		XCTAssertFalse(publicKey.isValid_fallback(signature: refernceSignature, for: data2)) // explicit fallback
		XCTAssertFalse(referencePublicKey.isValidSignature(refernceSignature, for: data2))
	}

	func testAlteredPackageValidation() throws {
		let rootKey = try PrivateKey()
		let publicKey = rootKey.publicKey

		let signatureVerifier = SignatureVerifier(key: { publicKey })
		let package = try SAPDownloadedPackage.makePackage(key: rootKey)

		XCTAssertTrue(signatureVerifier(package))

		// flip a random bit
		var bin = [UInt8](package.bin)
		let index = Int.random(in: 1..<bin.count)
		bin[index] ^= 0x1
		let alteredBin = Data(bin)

		XCTAssertNotEqual(package.bin.sha256(), alteredBin.sha256())
		let alteredPackage = SAPDownloadedPackage(keysBin: alteredBin, signature: package.signature)
		
		XCTAssertFalse(signatureVerifier(alteredPackage))
	}
}
