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
import CommonCrypto
import CryptoKit

extension Data {

	/// - parameter data: Byte stream of the .bin file
	func verify(_ data: Data) throws -> Bool {
		// TODO: Get key as String, no need to have it.
		// Openssl will help, something like this (might need tweaking)
		// openssl pkey -pubin -in pubkey.pem -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64

		// ⬇️ Check if right
		let keyData = Data(base64Encoded: "3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q==")!
		let pubKey = try P256.Signing.PublicKey(rawRepresentation: keyData)
		// 1 Get pub key
		// 2 build signature out of the .sig binary
		// 3 Build digest from bin using SHA256
		// 4 Verify signature for digest with public key
		// TODO: Check if we need to remove the utf8 header from the export.bin
		// TODO: Check if we need to use the digest function instead of the data function below. If so, we need to SHA256 the byte stream first
		// TODO: Apple checks the keys for us, we only really need to check the App Config
		// TODO: Fix for incorrect parameter size error when executing this statement: P256.Signing.ECDSASignature(rawRepresentation: self)
		return pubKey.isValidSignature(try P256.Signing.ECDSASignature(rawRepresentation: self), for: data)
	}
}
