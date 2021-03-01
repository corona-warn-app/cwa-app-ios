//
// 🦠 Corona-Warn-App
//

@testable import ENA
import FMDB
import XCTest

final class SQLiteKeyValueStoreTests: XCTestCase {
	private let storeDir = FileManager()
		.temporaryDirectory
		.appendingPathComponent(
			"SQLiteKeyValueStoreTests",
			isDirectory: true
	)

	private var kvStore: SQLiteKeyValueStore!
	let group = DispatchGroup()

	let rawMockData: [(key: String, data: Data)] = [
		("key", Data("testing".utf8)),
		("key2", Data("testing2".utf8)),
		("developerSubmissionBaseURLOverride", Data("testing3".utf8)),
		("developerDistributionBaseURLOverride", Data("testing4".utf8)),
		("developerVerificationBaseURLOverride", Data("testing5".utf8))
	]

	private func removeAndRecreateDir() throws {
		let fileManager = FileManager()
		if fileManager.fileExists(atPath: storeDir.path) {
			try fileManager.removeItem(at: storeDir)
		}
		try fileManager.createDirectory(
			at: storeDir,
			withIntermediateDirectories: true,
			attributes: nil
		)
		// Old DB is deinited and hence connection closed at every setUp() call
		kvStore = try SQLiteKeyValueStore(with: storeDir, key: "password")
	}

	override func setUpWithError() throws {
		try super.setUpWithError()
		try removeAndRecreateDir()
	}

	override func tearDownWithError() throws {
		try super.tearDownWithError()
		try removeAndRecreateDir()
		kvStore = nil
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

	func testClearAll_Success() throws {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[1].key] = rawMockData[1].data

		try kvStore.clearAll(key: "newPassword")

		XCTAssertNil(kvStore[rawMockData[0].key])
		XCTAssertNil(kvStore[rawMockData[1].key])
	}

	func testFlush_OverridesNotCleared() throws {
		kvStore[rawMockData[0].key] = rawMockData[0].data
		kvStore[rawMockData[1].key] = rawMockData[1].data

		kvStore[rawMockData[2].key] = rawMockData[2].data
		kvStore[rawMockData[3].key] = rawMockData[3].data
		kvStore[rawMockData[4].key] = rawMockData[4].data

		try kvStore.flush()

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
		XCTAssertTrue(try XCTUnwrap(kvStore["a"]).isEmpty)
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

		let result = group.wait(timeout: .now() + .extraLong)
		XCTAssertEqual(result, .success)
		for j in 0...1000 {
			if j.isMultiple(of: 2) {
				XCTAssertNil(self.kvStore["key\(j)"])
			} else {
				XCTAssertEqual(self.kvStore["key\(j)"], Data("value\(j)".utf8))
			}
		}
	}

	func testDate() {
		// 2020 June 9th
		let birthday = Date(timeIntervalSince1970: 1591724655)

		kvStore["birthday"] = birthday
		guard let out = kvStore["birthday"] as Date? else {
			XCTFail("store should give back the date that was put in")
			return
		}

		XCTAssertTrue(
			Calendar.current.isDate(birthday, equalTo: out, toGranularity: .minute)
		)
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
