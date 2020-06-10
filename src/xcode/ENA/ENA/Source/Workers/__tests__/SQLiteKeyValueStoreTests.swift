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
	let group = DispatchGroup()

	let rawMockData: [(key: String, data: Data)] = [
		("key", Data("testing".utf8)),
		("key2", Data("testing2".utf8)),
		("developerSubmissionBaseURLOverride", Data("testing3".utf8)),
		("developerDistributionBaseURLOverride", Data("testing4".utf8)),
		("developerVerificationBaseURLOverride", Data("testing5".utf8))
	]

	override func setUp() {
		super.setUp()
		// Old DB is deinited and hence connection closed at every setUp() call
		kvStore = SQLiteKeyValueStore(with: URL(staticString:":memory:"), key: "password")
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
		let someOtherData = Data("someOtherData".utf8)
		kvStore[rawMockData[0].key] = someOtherData
		XCTAssertEqual(kvStore[rawMockData[0].key], someOtherData)
	}

	func testClearAll_Success() {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[1].key] = rawMockData[1].data

		kvStore.clearAll(key: "newPassword")

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
		XCTAssertNil(kvStore["b"])
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

	func testThreadSafety() {
		for i in 0...1000 {
			group.enter()

			DispatchQueue.global().async {
				let sleepVal = UInt32.random(in: 0...1000)
				usleep(sleepVal)
				self.kvStore["key\(i)"] = Data("value\(i)".utf8)
				if i.isMultiple(of: 2) {
					self.kvStore["key\(i)"] = nil
				}
				self.group.leave()
			}
		}

		let result = group.wait(timeout: DispatchTime.now() + 5)
		XCTAssert(result == .success)
		for j in 0...1000 {
			if j.isMultiple(of: 2) {
				XCTAssertNil(self.kvStore["key\(j)"])
			} else {
				XCTAssertEqual(self.kvStore["key\(j)"], Data("value\(j)".utf8))
			}
		}
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
