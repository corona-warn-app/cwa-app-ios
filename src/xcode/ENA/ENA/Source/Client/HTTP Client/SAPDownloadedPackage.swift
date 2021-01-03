//
// 🦠 Corona-Warn-App
//

import Foundation
import ZIPFoundation

/// A combined binary file (zipped) and the corresponding verification signature.
struct SAPDownloadedPackage: Fingerprinting {
	// MARK: Creating a Key Package

	init(keysBin: Data, signature: Data) {
		self.bin = keysBin
		self.signature = signature
		self.fingerprint = bin.sha256String()
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

	/// The zipped  key package
	let bin: Data
	/// The file-verification signature
	let signature: Data
	/// The SHA256 string of the package `bin`
	let fingerprint: String

	// MARK: - Verification

	typealias Verification = (SAPDownloadedPackage) -> Bool

	struct Verifier {
		private let getPublicKey: PublicKeyProviding

		init(key provider: @escaping PublicKeyProviding = DefaultPublicKeyProvider) {
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
					let signature = try? ECDSASignature(derRepresentation: signatureData)
				else {
					Log.warning("Could not validate signature of downloaded package", log: .api)
					continue
				}

				if publicKey.isValid(signature: signature, for: package.bin) {
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

extension Archive {
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
