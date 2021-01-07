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
import ZIPFoundation


extension Archive {

	func extractAppConfiguration() throws -> SAP_Internal_V2_ApplicationConfigurationIOS {
		guard let binEntry = self["default_app_config_ios.bin"] else {
			throw FingerprintError.entryNotFound(entryID: "default_app_config.bin")
		}
		guard let hashEntry = self["default_app_config_ios.sha256"] else {
			throw FingerprintError.entryNotFound(entryID: "default_app_config.sha256")
		}

		do {
			let hash = try extractData(from: hashEntry)
			let bin = try extractData(from: binEntry)

			let hashString = String(data: hash, encoding: .utf8)
			let config = try SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: bin)

			// we currently compare the raw bin instead of the deserialized object
			guard /*config.fingerprint*/ bin.sha256String() == hashString else {
				Log.error("Fingerprint mismatch", log: .localData)
				throw FingerprintError.binaryNotValidated
			}

			return config
		} catch {
			Log.error("Extraction error: \(error)", log: .localData, error: error)
			throw error
		}
	}
}

enum FingerprintError: Error {
	case binaryNotValidated
	case entryNotFound(entryID: String)
}

protocol Fingerprinting {
	var fingerprint: String { get }
}

extension SAP_Internal_V2_ApplicationConfigurationIOS: Fingerprinting {

	var fingerprint: String {
		do {
			let data = try serializedData()
			return data.sha256String()
		} catch {
			Log.error("Cannot fingerprint \(self)", log: .localData, error: error)
			return ""
		}
	}
}
