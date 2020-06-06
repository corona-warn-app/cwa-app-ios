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
	
	private static let nonProductionKey = "3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
	private static let productionKey = "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
	
	// How to get current environment?
	enum Environment {
		case production
		case nonProduction
		case unknown

		var publicKeyString: String {
			self == .production ? productionKey : nonProductionKey
		}
	}

	enum KeyError: Error {
		/// It was not possible to create the base64 encoded data from the public key string
		case encodingError
		case createError
		case environmentError
	}
	
	static func getPublicKeyData(_ applictionBundle: String) throws -> Data {
		let env = try getEnvironmentForApplicationBundle(applictionBundle)
		
		guard let data = Data(base64Encoded: env.publicKeyString) else {
			throw KeyError.encodingError
		}

		return data
	}
	
	static private func getEnvironmentForApplicationBundle(_ applicationBundle: String) throws -> Environment{
		if(applicationBundle == "de.rki.coronawarnapp"){
			return .production
		} else if(applicationBundle == "de.rki.coronawarnapp-dev"){
			return .nonProduction
		} else {
			throw KeyError.environmentError
		}
	}
}
