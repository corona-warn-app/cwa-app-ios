//
// 🦠 Corona-Warn-App
//

import Foundation

extension CFDictionary {

	class func keychainQueryForDeleting(
		account: String,
		service: String
	) -> CFDictionary {
		[
			kSecAttrService: service,
			kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: account
			] as CFDictionary
	}

	class func keychainQueryForAdding(
		account: String,
		service: String,
		data: Data
	) -> CFDictionary {
		[
			kSecAttrService: service,
			kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
			kSecClass: kSecClassGenericPassword,
			kSecAttrAccount: account,
			kSecValueData: data
			] as CFDictionary
	}

	class func keychainQueryForGetting(
		account: String,
		service: String
	) -> CFDictionary {
		[
			kSecAttrService: service,
			kSecAttrAccount: account,
			kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
			kSecClass: kSecClassGenericPassword,
			kSecReturnData: kCFBooleanTrue as Any,
			kSecMatchLimit: kSecMatchLimitOne
			] as CFDictionary
	}
}
