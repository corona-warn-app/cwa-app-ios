//
// 🦠 Corona-Warn-App
//

import XCTest
#if canImport(CryptoKit)
import CryptoKit
#endif
@testable import ENA

extension StaticString: Equatable {
	public static func == (lhs: StaticString, rhs: StaticString) -> Bool {
		// swiftlint:disable:next identical_operands
		return "\(lhs)" == "\(rhs)"
	}
}

final class PublicKeyProviderTests: XCTestCase {

	func testThatKeysHaveNotBeenAlteredAccidentally() {
		XCTAssertEqual(
			PublicKeyEnv.production.stringRepresentation,
			"c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
		)
		XCTAssertEqual(
			PublicKeyEnv.development.stringRepresentation,
			"3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
		)
	}
	
	// There was a bug in our code that converted the string rep. of the key to plain unicode instead of base64 encoded data.
	func testDefaultPublicKeyFromString() throws {
		guard #available(iOS 13.0, *) else {
		   throw XCTSkip("Unsupported iOS version")
		}

		let pk: StaticString = "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
		let data = Data(staticBase64Encoded: pk)

		// the fallback in `DefaultPublicKeyFromString(pk)` - the default CryptoKit implementation is our reference
		let publicKey = PublicKey(with: pk)
		// we have a valid assumption that CryptoKit is somewhat working…
		let referenceKey = try P256.Signing.PublicKey(rawRepresentation: data)

		XCTAssertEqual(publicKey.rawRepresentation, referenceKey.rawRepresentation)
	}
	
}
