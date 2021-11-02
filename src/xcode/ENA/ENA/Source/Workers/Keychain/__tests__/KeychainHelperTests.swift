//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class KeychainHelperTests: CWATestCase {

	let serviceID = "testservice"
	let testKey = "test"

	override func tearDownWithError() throws {
		try super.tearDownWithError()
		let keychain = try KeychainHelper(service: serviceID)
		try keychain.clearInKeychain(key: testKey)
	}

	func testHelperInit() throws {
		XCTAssertNoThrow(try KeychainHelper(service: serviceID))
		XCTAssertThrowsError(try KeychainHelper(service: ""), "Expected initialization error!") { error in
			XCTAssertNotNil(error as? KeychainError)
		}
	}

    func testDatabaseKeyGeneration() throws {
		let keychain = try KeychainHelper(service: serviceID)

		let key = try keychain.generateDatabaseKey(storeAtKeychainKey: SecureStore.encryptionKeyKeychainKey)
		XCTAssertFalse(key.isEmpty)
		XCTAssertNotNil(keychain.loadFromKeychain(key: SecureStore.encryptionKeyKeychainKey))
    }

	func testKeyRetrieval() throws {
		let keychain = try KeychainHelper(service: serviceID)
		guard let testData = "foo".data(using: .utf8) else {
			XCTFail("Expected to convert test string to `Data`")
			return
		}

		try keychain.saveToKeychain(key: testKey, data: testData)
		guard let retrieved = keychain.loadFromKeychain(key: testKey) else {
			XCTFail("Expected data for the given key")
			return
		}
		XCTAssertEqual(String(data: retrieved, encoding: .utf8), "foo")
	}

	func testFailingKeyRetrieval() throws {
		let keychain = try KeychainHelper(service: serviceID)
		let retrieved = keychain.loadFromKeychain(key: testKey)
		XCTAssertNil(retrieved)
	}

	func testKeyRemoval() throws {
		let keychain = try KeychainHelper(service: serviceID)

		let key = try keychain.generateDatabaseKey(storeAtKeychainKey: SecureStore.encryptionKeyKeychainKey)
		XCTAssertFalse(key.isEmpty)
    }
}
