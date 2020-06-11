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

import Foundation

enum KeychainHelper {
	// swiftlint:disable:next force_unwrapping
	private static let _service = Bundle.main.bundleIdentifier!

	static func saveToKeychain(key: String, data: Data) -> Bool {

		let deleteResult = SecItemDelete(
			.keychainQueryForDeleting(
				account: key,
				service: _service
			)
		)

		if deleteResult != errSecSuccess && deleteResult != errSecItemNotFound {
			if let message = SecCopyErrorMessageString(deleteResult, nil) {
				logError(message: "Failed to delete keychain item '\(key)' due to: \(message as String)")
			} else {
				logError(message: "Failed to delete keychain item '\(key)' due to unknown error")
			}
		}

		let addResult = SecItemAdd(
			.keychainQueryForAdding(
				account: key,
				service: _service,
				data: data
			),
			nil
		)

		if addResult != errSecSuccess {
			if let message = SecCopyErrorMessageString(addResult, nil) {
				logError(message: "Failed to add keychain item '\(key)' due to: \(message as String)")
			} else {
				logError(message: "Failed to add keychain item '\(key)' due to unknown error")
			}
		}

		return addResult == errSecSuccess
	}

	static func loadFromKeychain(key: String) -> Data? {
		var dataRef: AnyObject?
		let status: OSStatus = SecItemCopyMatching(
			.keychainQueryForGetting(account: key, service: _service),
			&dataRef
		)
		if
			let dataRef = dataRef,
			status == errSecSuccess,
			CFGetTypeID(dataRef) == CFDataGetTypeID() {
			return dataRef as? Data
		}
		return nil
	}

	static func generateDatabaseKey() -> String? {
		var bytes = [UInt8](repeating: 0, count: 32)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			logError(message: "Error creating random bytes.")
			return nil
		}
		let key = "x'\(Data(bytes).hexEncodedString())'"
		if saveToKeychain(key: "secureStoreDatabaseKey", data: Data(key.utf8)) == false {
			logError(message: "Unable to save Key to Keychain")
			return nil
		}
		return key
	}
}
