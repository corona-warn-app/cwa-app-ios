//
// 🦠 Corona-Warn-App
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
			Log.error("Error creating random bytes.", log: .api)
			throw KeychainError.keyGenerationFail
		}

		let key = "x'\(Data(bytes).hexEncodedString())'"
		try saveToKeychain(key: SecureStore.keychainDatabaseKey, data: Data(key.utf8))
		return key
	}

	/// Generates and stores a new random database key
	/// - Throws: a `KeychainError` in case the generation or database save fails
	/// - Returns: the newly created key
	func generateContactDiaryDatabaseKey() throws -> String {
		var bytes = [UInt8](repeating: 0, count: 32)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			Log.error("Error creating random bytes.", log: .api)
			throw KeychainError.keyGenerationFail
		}

		let key = "x'\(Data(bytes).hexEncodedString())'"
		try saveToKeychain(key: ContactDiaryStore.encriptionKeyKey, data: Data(key.utf8))
		return key
	}
}
