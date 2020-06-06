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

enum KeyError: Error {
	/// It was not possible to create the base64 encoded data from the public key string
	case encodingError
	case createError
	case environmentError
}

protocol PublicKeyStore {
	func publicKey(for bundleID: String) throws -> P256.Signing.PublicKey
}

final class ProductionPublicKeyStore: PublicKeyStore {

	private let nonProductionKey = "3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
	private let productionKey = "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="

	func publicKey(for bundleID: String) throws -> P256.Signing.PublicKey {
		let keyData: Data?
		switch bundleID {
		case "de.rki.coronawarnapp":
			keyData = Data(base64Encoded: productionKey)
		case "de.rki.coronawarnapp-dev":
			keyData = Data(base64Encoded: nonProductionKey)
		default:
			throw KeyError.environmentError
		}

		guard let data = keyData else {
			throw KeyError.encodingError
		}

		return try P256.Signing.PublicKey(rawRepresentation: data)
	}
}
