////
// 🦠 Corona-Warn-App
//

import XCTest
import CryptoKit
@testable import ENA


@available(iOS 13.0, *)
class CryptoFallbackTests: XCTestCase {

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

}
