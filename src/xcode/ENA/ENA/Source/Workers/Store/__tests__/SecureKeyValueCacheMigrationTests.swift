//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SecureKeyValueCacheMigrationTests: XCTestCase {

	func testGIVEN_SecureCacheVersion_0_WHEN_Init_THEN_VersionIsMigratedTo_1() {
		// GIVEN
		let store = MockTestStore()
		XCTAssertEqual(store.keyValueCacheVersion, 0)

		// WHEN
		_ = SecureKeyValueCache(subDirectory: "TestALot", store: store)

		// THEN
		XCTAssertEqual(store.keyValueCacheVersion, 1)
	}

	func testGIVEN_SecureCacheVersion_1_WHEN_Init_THEN_VersionDidNotChange() {
		// GIVEN
		let store = MockTestStore()
		store.keyValueCacheVersion = 1
		XCTAssertEqual(store.keyValueCacheVersion, 1)

		// WHEN
		_ = SecureKeyValueCache(subDirectory: "TestALot", store: store)

		// THEN
		XCTAssertEqual(store.keyValueCacheVersion, 1)
	}

}
