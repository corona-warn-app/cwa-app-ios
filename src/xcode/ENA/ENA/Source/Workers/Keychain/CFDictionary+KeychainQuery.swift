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
