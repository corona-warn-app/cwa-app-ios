//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

@testable import ENA
import FMDB
import XCTest

final class SQLiteKeyValueStoreTests: XCTestCase {

	private var kvStore: SQLiteKeyValueStore!

	let rawMockData: [(key: String, data: Data)] = [
		// swiftlint:disable force_unwrapping
		("key", "testing".data(using: .utf8)!),
		("key2", "testing2".data(using: .utf8)!),
		("developerSubmissionBaseURLOverride", "testing3".data(using: .utf8)!),
		("developerDistributionBaseURLOverride", "testing4".data(using: .utf8)!),
		("developerVerificationBaseURLOverride", "testing5".data(using: .utf8)!)
		// swiftlint:enable force_unwrapping
	]

	override func setUp() {
		super.setUp()
		// Old DB is deinited and hence connection closed at every setUp() call
		kvStore = SQLiteKeyValueStore(with: URL(staticString: "file::memory"))
	}

	// MARK: - Positive Tests

	func testStoreRawData_Success() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		XCTAssertEqual(kvStore[rawMockData[0].key], rawMockData[0].data)
	}

	func testNilOutValue_Success() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[0].key] = nil
		XCTAssertNil(kvStore[rawMockData[0].key])
	}

	func testOverwriteValue_Success() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		// swiftlint:disable:next force_unwrapping
		let someOtherData = "someOtherData".data(using: .utf8)!
		kvStore[rawMockData[0].key] = someOtherData
		XCTAssertEqual(kvStore[rawMockData[0].key], someOtherData)
	}

	func testClearAll_Success() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[1].key] = rawMockData[1].data

		kvStore.clearAll()

		XCTAssertNil(kvStore[rawMockData[0].key])
		XCTAssertNil(kvStore[rawMockData[1].key])
	}

	func testFlush_OverridesNotCleared() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[1].key] = rawMockData[1].data

		kvStore[rawMockData[2].key] = rawMockData[2].data
		kvStore[rawMockData[3].key] = rawMockData[3].data
		kvStore[rawMockData[4].key] = rawMockData[4].data

		kvStore.flush()

		XCTAssertNil(kvStore[rawMockData[0].key])
		XCTAssertNil(kvStore[rawMockData[1].key])
		// A flush clears most values except for a few known developer override keys
		XCTAssertEqual(kvStore[rawMockData[2].key], rawMockData[2].data)
		XCTAssertEqual(kvStore[rawMockData[3].key], rawMockData[3].data)
		XCTAssertEqual(kvStore[rawMockData[4].key], rawMockData[4].data)
	}

	func testStoreCodable_Success() {
		let someCodable = SomeCodable(someDouble: 1.1)
		kvStore["someCodable"] = someCodable

		XCTAssertEqual(kvStore["someCodable"], someCodable)
	}

	func testCodableStore_ValueForKeyNotExists() {
		XCTAssertNil(kvStore["abc"] as Int64?)
	}

	func test_ValueForKeyNotExists() {
		XCTAssertNil(kvStore["a"])
	}

	func testStore_EmptyData() {
		kvStore["a"] = Data()
		XCTAssert(kvStore["a"]?.isEmpty == true)
	}

	// MARK: - Negative Tests

	func testEncodingError_ReturnNil() {
		kvStore["shouldFail"] = SomeCodable(someDouble: Double.nan)
		// Since encoding failed, nothing is stored
		XCTAssertNil(kvStore["shouldFail"])
	}

	func testDecodingError_ReturnNil() {
		kvStore["someCodable"] = SomeCodable(someDouble: 1.1)
		XCTAssertNil(kvStore["someCodable"] as SomeOtherCodable?)
	}
}

private extension SQLiteKeyValueStoreTests {
	// Also Equatable for ease of use - synthesized conformance will compare all properties
	struct SomeCodable: Codable, Equatable {
		let someDouble: Double
	}

	struct SomeOtherCodable: Codable, Equatable {
		let someString: String
	}
}
