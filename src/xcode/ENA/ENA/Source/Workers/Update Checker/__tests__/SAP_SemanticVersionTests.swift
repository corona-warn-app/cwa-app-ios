//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
@testable import ENA

final class SAP_SemanticVersionTests: XCTestCase {
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
		XCTAssert(Version(1, 0, 0) < Version(2, 0, 0))

		// Equal versions are never smaller
		XCTAssertFalse(Version(0, 0, 0) < Version(0, 0, 0))
		XCTAssertFalse(Version(1, 0, 0) < Version(1, 0, 0))
		XCTAssertFalse(Version(0, 1, 0) < Version(0, 1, 0))
		XCTAssertFalse(Version(0, 0, 1) < Version(0, 0, 1))

		// Smallest possible version is still bigger than 0
		XCTAssert(Version(0, 0, 0) < Version(0, 0, 1))

		XCTAssert(Version(1, 0, 0) < Version(2, 0, 0))
		XCTAssert(Version(0, 1, 0) < Version(0, 2, 0))
		XCTAssert(Version(0, 0, 1) < Version(0, 0, 2))
    }
}

private typealias Version = SAP_SemanticVersion
private extension SAP_SemanticVersion {
	init(_ major: Int, _ minor: Int, _ patch: Int) {
		self.init()
		self.major = UInt32(major)
		self.minor = UInt32(minor)
		self.patch = UInt32(patch)
	}
}
