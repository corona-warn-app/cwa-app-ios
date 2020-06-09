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
	static func saveToKeychain(key: String, data: Data) -> OSStatus {
		let query = [
			kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: key,
			kSecValueData as String: data ] as [String: Any]

		SecItemDelete(query as CFDictionary)
		return SecItemAdd(query as CFDictionary, nil)
	}

	static func loadFromKeychain(key: String) -> Data? {
		let query = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: kCFBooleanTrue as Any,
			kSecMatchLimit as String: kSecMatchLimitOne
			] as [String: Any]

		var dataTypeRef: AnyObject?
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
		if status == noErr {
			return dataTypeRef as? Data ?? nil
		} else {
			return nil
		}
	}

	static func generateDatabaseKey() -> String? {
		var bytes = [UInt8](repeating: 0, count: 32)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			logError(message: "Error creating random bytes.")
			return nil
		}
		let key = "x'\(Data(bytes).hexEncodedString())'"
		if saveToKeychain(key: "secureStoreDatabaseKey", data: Data(key.utf8)) != noErr {
			logError(message: "Unable to save Key to Keychain")
			return nil
		}
		return key
	}
}
