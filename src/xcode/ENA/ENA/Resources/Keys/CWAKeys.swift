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
import CryptoKit

enum CWAKeys {
	// How to get current environment?
	enum Environment {
		case production
		case development

		var publicKeyString: String {
			self == .production ? prodPublic : devPublic
		}
	}

	enum KeyError: Error {
		/// It was not possible to create the base64 encoded data from the public key string
		case encodingError
		case createError
	}

	static func getPubSecKey(for environment: Environment) throws -> SecKey {
		guard let data = Data(base64Encoded: environment.publicKeyString) else {
			throw KeyError.encodingError
		}

		let attributes: [String: Any] = [
			kSecAttrKeyType as String: kSecAttrKeyTypeEC,
			kSecAttrKeyClass as String: kSecAttrKeyClassPublic
		]

		var error: Unmanaged<CFError>?
		let key = SecKeyCreateWithData(data as NSData, attributes as CFDictionary, &error)

		if let error = error { throw error.takeRetainedValue() as Error }

		guard let secKey = key else { throw KeyError.createError }

		return secKey
	}

	/*
	Keys here were generated with script from raw text PEM files like so:
	./getRawKey.sh ./keys/de.rki.coronawarnapp-prod-public.pem
	*/

	private static let devPublic = "BNwWE8a9h7iWEBvnexM7uikvBhGxZIhL8iRYNI/gvN/YE40+o+x6NBF12f2tO2X7ynAtnJnNUrp7K6lPSaL9SeU="
	private static let prodPublic = "BHOwxLLXFCEXMpN+TmAyfef4U4N1FYbGg1yk9MyuzYRz16Ms4qRJzqdxsjVw1aWj4t3AH0JsXrhTGQCF9vugOV4="
}
