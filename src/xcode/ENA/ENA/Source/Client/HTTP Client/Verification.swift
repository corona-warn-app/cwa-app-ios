////
// 🦠 Corona-Warn-App
//

import Foundation

// MARK: - Verification

protocol SignatureVerification {
	
	/// Verifies a SAPDownloadedPackage
	func verify(_ package: SAPDownloadedPackage) -> Bool
}

struct SignatureVerifier: SignatureVerification {
	
	// MARK: - Init
	
	init(key provider: @escaping PublicKeyProviding = DefaultPublicKeyProvider) {
		getPublicKey = provider
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol SignatureVerification
	
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
	
	// MARK: - Private
	
	private let getPublicKey: PublicKeyProviding
}
