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

class KeychainHelperTests: XCTestCase {

	let serviceID = "testservice"
	let testKey = "test"

	override func tearDownWithError() throws {
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

		let key = try keychain.generateDatabaseKey()
		XCTAssertFalse(key.isEmpty)
		XCTAssertNotNil(keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey))
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

		let key = try keychain.generateDatabaseKey()
		XCTAssertFalse(key.isEmpty)
    }
}
