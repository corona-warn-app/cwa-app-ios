//
// 🦠 Corona-Warn-App
//

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

	// MARK: - Verification

	typealias Verification = (SAPDownloadedPackage) -> Bool

	struct Verifier {
		private let getPublicKey: PublicKeyProvider

		init(key provider: @escaping PublicKeyProvider = DefaultPublicKeyProvider) {
			getPublicKey = provider
		}

		func verify(_ package: SAPDownloadedPackage) -> Bool {
			guard
				let parsedSignatureFile = try? SAP_External_Exposurenotification_TEKSignatureList(serializedData: package.signature)
				else {
				return false
			}

			let publicKey = getPublicKey()

			for signatureEntry in parsedSignatureFile.signatures {
				let signatureData: Data = signatureEntry.signature
				guard
					let signature = try? P256.Signing.ECDSASignature(derRepresentation: signatureData)
				else {
					Log.warning("Could not validate signature of downloaded package", log: .api)
					continue
				}

				if publicKey.isValidSignature(signature, for: package.bin) {
					return true
				}
			}

			return false
		}

		func callAsFunction(_ package: SAPDownloadedPackage) -> Bool {
			verify(package)
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
