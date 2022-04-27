//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SecureKeyValueCacheMigrationTests: XCTestCase {

	private static let subDirectory = "TestALot"

	private static func databaseDirectory(at subDirectory: String) throws -> URL {
		try FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(subDirectory)
	}

	override class func tearDown() {
		do {
			let directoryURL = try Self.databaseDirectory(at: Self.subDirectory)
			let fileManager = FileManager.default
			try fileManager.removeItem(atPath: directoryURL.path)
		} catch {
			Log.error("tear down of test failed")
		}
	}

	func testGIVEN_SecureCacheVersion_0_WHEN_InitWillMigrate_THEN_toSecureCacheLatestVersion() {
		// GIVEN
		let store = MockTestStore()
		XCTAssertEqual(store.keyValueCacheVersion, 0)

		// WHEN
		_ = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)

		// THEN
		XCTAssertEqual(store.keyValueCacheVersion, SecureKeyValueCache.latestVersion)
	}

	func testGIVEN_SecureCacheLatestVersion_WHEN_Init_THEN_VersionDidNotChange() {
		// GIVEN
		let store = MockTestStore()
		store.keyValueCacheVersion = SecureKeyValueCache.latestVersion
		XCTAssertEqual(store.keyValueCacheVersion, SecureKeyValueCache.latestVersion)

		// WHEN
		_ = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)

		// THEN
		XCTAssertEqual(store.keyValueCacheVersion, SecureKeyValueCache.latestVersion)
	}

	func testGIVEN_SecureCacheLatestVersion_WHEN_AddCachedData_THEN_NewInstanceContainsCachedData() throws {
		// GIVEN
		/// fake version 1 to skip migration and insert cached data
		let store = MockTestStore()
		store.keyValueCacheVersion = SecureKeyValueCache.latestVersion

		let cache = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)
		cache["testKey"] = CacheData.fake(eTag: "12345")
		let cachedValue = try XCTUnwrap(cache["testKey"])
		XCTAssertEqual(cachedValue.eTag, "12345")

		let newerCache = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)
		let newerCachedValue = try XCTUnwrap(newerCache["testKey"])
		XCTAssertEqual(newerCachedValue.eTag, "12345")
	}

	func testGIVEN_SecureCacheVersion_0_WHEN_InitWithMigration_THEN_DataIsCleared() throws {
		// GIVEN
		/// fake version 1 to skip migration and insert cached data
		let store = MockTestStore()
		store.keyValueCacheVersion = 1

		let cache = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)
		cache["testKey"] = CacheData.fake(eTag: "12345")
		let cachedValue = try XCTUnwrap(cache["testKey"])
		XCTAssertEqual(cachedValue.eTag, "12345")

		/// rollback version number to trigger migration
		store.keyValueCacheVersion = 0

		let newerCache = SecureKeyValueCache(subDirectory: Self.subDirectory, store: store)
		XCTAssertNil(newerCache["testKey"])
	}

}
