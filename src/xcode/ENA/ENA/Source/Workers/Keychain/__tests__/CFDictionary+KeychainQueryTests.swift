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

class CFDictionary_KeychainQueryTests: XCTestCase {


	func testGet() {
		guard let query = CFDictionary.keychainQueryForGetting(
			account: "sap",
			service: "mysuperservice"
			) as? [CFString: Any] else {
				XCTFail("invalid dictionary")
				return
		}

		XCTAssertEqual(
			query[kSecAttrService] as? String,
			"mysuperservice"
		)

		XCTAssertEqual(
			query[kSecAttrAccount] as? String,
			"sap"
		)

		XCTAssertEqual(
			query[kSecClass] as? String,
			kSecClassGenericPassword as String
		)

		XCTAssertEqual(
			query[kSecAttrAccessible] as? String,
			kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
		)

		XCTAssertEqual(
			query[kSecMatchLimit] as? String,
			kSecMatchLimitOne as String
		)

		let returnData = query[kSecReturnData] as CFTypeRef
		XCTAssertEqual(CFGetTypeID(returnData), CFBooleanGetTypeID())

		// swiftlint:disable:next force_cast
		let returnDataBool = returnData as! CFBoolean

		XCTAssertEqual(
			CFBooleanGetValue(returnDataBool),
			CFBooleanGetValue(kCFBooleanTrue)
		)
	}

	func testAdd() {
		guard let query = CFDictionary.keychainQueryForAdding(
			account: "sap",
			service: "mysuperservice",
			data: Data("1337".utf8)
			) as? [CFString: Any] else {
				XCTFail("invalid dictionary")
				return
		}

		XCTAssertEqual(
			query[kSecAttrService] as? String,
			"mysuperservice"
		)

		XCTAssertEqual(
			query[kSecAttrAccount] as? String,
			"sap"
		)

		XCTAssertEqual(
			query[kSecClass] as? String,
			kSecClassGenericPassword as String
		)

		XCTAssertEqual(
			query[kSecAttrAccessible] as? String,
			kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
		)

		XCTAssertEqual(
			query[kSecValueData] as? Data,
			Data("1337".utf8)
		)
	}

    func testDelete() {
		guard let query = CFDictionary.keychainQueryForDeleting(
			account: "sap",
			service: "mysuperservice"
		) as? [CFString: Any] else {
			XCTFail("invalid dictionary")
			return
		}

		XCTAssertEqual(
			query[kSecAttrService] as? String,
			"mysuperservice"
		)

		XCTAssertEqual(
			query[kSecAttrAccount] as? String,
			"sap"
		)

		XCTAssertEqual(
			query[kSecClass] as? String,
			kSecClassGenericPassword as String
		)

		XCTAssertEqual(
			query[kSecAttrAccessible] as? String,
			kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
		)
	}
}
