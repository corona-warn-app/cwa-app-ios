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
	/// Attempt to decypt the data with the given `SecKey`
	///
	/// - parameter key: `SecKey` to decrypt the data with
	/// - returns: decrypted `Data`, `nil` if decryption fails
	func decrypted(with key: SecKey) -> Data? {
//		var bufferSize = SecKeyGetBlockSize(key)
//		var decryptedBytes = [UInt8](repeating: 0, count: bufferSize)
//		let encryptedBytes = [UInt8](self)
//
//		let status = SecKeyDecrypt(key, SecPadding(rawValue: 0), encryptedBytes, bufferSize, &decryptedBytes, &bufferSize)
//		guard status == errSecSuccess else {
//			return nil
//		}
//
//		return Data(bytes: decryptedBytes, count: bufferSize)

		/*
		        status = SecKeyDecrypt(privateKey!, SecPadding.PKCS1, &messageEncrypted, messageEncryptedSize, &messageDecrypted, &messageDecryptedSize)
		*/

		/*
		size_t cipherBufferSize = [content length];
		void *cipherBuffer = malloc(cipherBufferSize);
		[content getBytes:cipherBuffer length:cipherBufferSize];
		size_t plainBufferSize = [content length];
		uint8_t *plainBuffer = malloc(plainBufferSize);
		OSStatus sanityCheck = SecKeyDecrypt(key,
		kSecPaddingPKCS1,
		cipherBuffer,
		cipherBufferSize,
		plainBuffer,
		&plainBufferSize);
		*/

		let cipherBufferSize = count
		var cipherBuffer = [UInt8](self)
		var plainBufferSize = count
		var plainBuffer = [UInt8](repeating: 0, count: plainBufferSize)

		let status = SecKeyDecrypt(key, SecPadding.PKCS1, cipherBuffer, cipherBufferSize, &plainBuffer, &plainBufferSize)
		guard status == errSecSuccess else {
			return nil
		}

		return Data(bytes: plainBuffer, count: plainBufferSize)
	}

	//data is the content of the bin file
	func verify(_ data: Data) throws -> Bool {
		guard let keyURL = Bundle.main.url(forResource: "trimmedRawKey", withExtension: "der") else { return false }

		let keyData = try Data(contentsOf: keyURL)
		let pubKey = try P256.Signing.PublicKey(rawRepresentation: keyData)

		return true
	}
}
