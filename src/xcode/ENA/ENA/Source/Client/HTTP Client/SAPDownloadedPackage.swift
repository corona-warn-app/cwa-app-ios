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
import CryptoKit

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
	/// - Neither the .bin or .sig data is encrypted (besides in transit), but the .sig file serves the signature
	/// - The server has signed this hash with their private key.
	///
	func verifySignature(with keystore: PublicKeyStore = ProductionPublicKeyStore()) throws -> Bool {
		
		guard let parsedSignatureFile = try? SAP_TEKSignatureList(serializedData: signature) else {
			return false
		}
		
		for signatureEntry in parsedSignatureFile.signatures {
			let signatureData: Data = signatureEntry.signature
			let publicKey = try keystore.publicKey(for: signatureEntry.signatureInfo.appBundleID)
			let signature = try P256.Signing.ECDSASignature(derRepresentation: signatureData)
				
			if publicKey.isValidSignature(signature, for: self.bin) {
				return true
			}
		}
		
		return false
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
