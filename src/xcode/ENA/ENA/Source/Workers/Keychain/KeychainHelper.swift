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

enum KeychainError: Error {
	case initializationError
	case clearItem(reason: String? = nil)
	case save(reason: String? = nil)
	case keyGenerationFail
}

struct KeychainHelper {

	/// The service this helper is registered to
	let service: String

	/// Initializer
	/// - Parameter service: the service to use; defaults to the main bundle id
	// swiftlint:disable:next force_unwrapping
	init(service: String = Bundle.main.bundleIdentifier!) throws {
		self.service = service
		if self.service.isEmpty { throw KeychainError.initializationError }
	}

	func clearInKeychain(key: String) throws {
		let deleteResult = SecItemDelete(
			.keychainQueryForDeleting(
				account: key,
				service: service
			)
		)
		// ignore 'item not found errors' as this might happen, e.g. on first launch
		if deleteResult != errSecSuccess && deleteResult != errSecItemNotFound {
			let message = SecCopyErrorMessageString(deleteResult, nil) ?? "unknown error" as CFString
			let reason = "Failed to delete existing keychain item '\(key)' due to \(message)"
			throw KeychainError.clearItem(reason: reason)
		}
	}

	func saveToKeychain(key: String, data: Data) throws {
		try clearInKeychain(key: key)
		let addResult = SecItemAdd(
			.keychainQueryForAdding(
				account: key,
				service: service,
				data: data
			),
			nil
		)

		if addResult != errSecSuccess {
			if let message = SecCopyErrorMessageString(addResult, nil) {
				let message = "Failed to add keychain item '\(key)' due to: \(message as String)"
				throw KeychainError.save(reason: message)
			} else {
				let message = "Failed to add keychain item '\(key)' due to unknown error"
				throw KeychainError.save(reason: message)
			}
		}
	}

	func loadFromKeychain(key: String) -> Data? {
		var dataRef: AnyObject?
		let status: OSStatus = SecItemCopyMatching(
			.keychainQueryForGetting(account: key, service: service),
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


	/// Generates and stores a new random database key
	/// - Throws: a `KeychainError` in case the generation or database save fails
	/// - Returns: the newly created key
	func generateDatabaseKey() throws -> String {
		var bytes = [UInt8](repeating: 0, count: 32)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			logError(message: "Error creating random bytes.")
			throw KeychainError.keyGenerationFail
		}

		let key = "x'\(Data(bytes).hexEncodedString())'"
		try saveToKeychain(key: SecureStore.keychainDatabaseKey, data: Data(key.utf8))
		return key
	}
}
