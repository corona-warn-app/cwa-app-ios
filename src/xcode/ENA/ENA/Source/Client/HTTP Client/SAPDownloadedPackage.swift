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

import Foundation
import ZIPFoundation

struct SAPDownloadedPackage {
	// MARK: Creating a Key Package

	init(keysBin: Data, signature: Data) {
		bin = keysBin
		self.signature = signature
	}

	init?(compressedData: Data) {
		guard let archive = Archive(data: compressedData, accessMode: .read) else {
			return nil
		}
		do {
			self = try archive.extractKeyPackage()
			try verifyHash()
		} catch {
			return nil
		}
	}

	// MARK: Properties

	let bin: Data
	let signature: Data
}

extension SAPDownloadedPackage {
	/// Verify that the .bin file actually originated from our server and was not tampered with.
	///
	/// This works as follows:
	/// - We store the public key of our server (depends on landscape, we have two public keys right now)
	/// - Neither the .bin or .sig data is encrypted (besides in transit), but the .sig file stores an encrypted SHA256 hash of the .bin file
	/// - The server has signed this hash with their private key.
	///
	/// The actual checking is performed as follows:
	/// 1. Deserialze the `signature` `Data` into the corresponding model `SAP_TEKSignature`
	/// 2. Decrypt the therein contained signature with out public key
	/// 3. We now have the SHA256 hash of the .bin file
	/// 4. Hash the .bin file, and compare the two.
	/// 5. If they match, we can be sure that they have not been tampered with and originated from our server.
	func verifyHash() throws {
		let parsedSignatureFile = try SAP_TEKSignature(serializedData: signature)
		let encryptedSignature = parsedSignatureFile.signature
		let key = try CWAKeys.getPubSecKey(for: .development)

		guard let decryptedHash = encryptedSignature.decrypted(with: key) else {
			logError(message: "Package signature decryption failed!")
			throw Archive.KeyPackageError.signatureCheckFailed
		}

		if decryptedHash != bin.sha256() {
			throw Archive.KeyPackageError.signatureCheckFailed
		}
	}
}

private extension Archive {
	typealias KeyPackage = (bin: Data, sig: Data)
	enum KeyPackageError: Error {
		case binNotFound
		case sigNotFound
		case signatureCheckFailed
	}

	func extractData(from entry: Entry) throws -> Data {
		var data = Data()
		try _ = extract(entry) { slice in
			data.append(slice)
		}
		return data
	}

	func extractKeyPackage() throws -> SAPDownloadedPackage {
		guard let binEntry = self["export.bin"] else {
			throw KeyPackageError.binNotFound
		}
		guard let sigEntry = self["export.sig"] else {
			throw KeyPackageError.sigNotFound
		}
		return SAPDownloadedPackage(
			keysBin: try extractData(from: binEntry),
			signature: try extractData(from: sigEntry)
		)
	}
}
