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
		case unknown

		var publicKeyString: String {
			self == .production ? prodPublic : devPublic
		}
	}

	enum KeyError: Error {
		/// It was not possible to create the base64 encoded data from the public key string
		case encodingError
		case createError
	}
	
	static func getPublicKeyData(_ applictionBundle: String) throws -> Data {
		let env = getEnvironmentForApplicationBundle(applictionBundle)
		
		guard let data = Data(base64Encoded: env.publicKeyString) else {
			throw KeyError.encodingError
		}

		return data
	}
	
	static private func getEnvironmentForApplicationBundle(_ applicationBundle: String) -> Environment{
		if(applicationBundle == "de.rki.coronawarnapp"){
			return .production
		} else if(applicationBundle == "de.rki.coronawarnapp-dev"){
			return .development
		} else {
			return .unknown
		}
	}

	private static let devPublic = "3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
	private static let prodPublic = "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
}
