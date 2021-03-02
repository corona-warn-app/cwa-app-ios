//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class SAP_Internal_SemanticVersionTests: XCTestCase {
	func testParseVersionString_Success() {
		let version = "1.2.3".semanticVersion
		XCTAssertNotNil(version)
		XCTAssertEqual(version?.major, 1)
		XCTAssertEqual(version?.minor, 2)
		XCTAssertEqual(version?.patch, 3)
	}

	func testParseVersionString_Fail_PlainWrong() {
		let version = "helloworld".semanticVersion
		XCTAssertNil(version)
	}

	func testParseVersionString_Fail_OneComponentWrong() {
		let version = "1.2.hello".semanticVersion
		XCTAssertNil(version)
	}

	func testParseVersionString_Fail_TwoComponentsWrong() {
		let version = "1.2".semanticVersion
		XCTAssertNil(version)
	}
	
    func testVersions() {
		XCTAssertLessThan(Version(1, 0, 0), Version(2, 0, 0))

		// Equal versions are never smaller
		XCTAssertEqual(Version(0, 0, 0), Version(0, 0, 0))
		XCTAssertEqual(Version(1, 0, 0), Version(1, 0, 0))
		XCTAssertEqual(Version(0, 1, 0), Version(0, 1, 0))
		XCTAssertEqual(Version(0, 0, 1), Version(0, 0, 1))

		// Smallest possible version is still bigger than 0
		XCTAssertLessThan(Version(0, 0, 0), Version(0, 0, 1))

		XCTAssertLessThan(Version(1, 0, 0), Version(2, 0, 0))
		XCTAssertLessThan(Version(0, 1, 0), Version(0, 2, 0))
		XCTAssertLessThan(Version(0, 0, 1), Version(0, 0, 2))
    }
}

private typealias Version = SAP_Internal_V2_SemanticVersion
private extension SAP_Internal_V2_SemanticVersion {
	init(_ major: Int, _ minor: Int, _ patch: Int) {
		self.init()
		self.major = UInt32(major)
		self.minor = UInt32(minor)
		self.patch = UInt32(patch)
	}
}
