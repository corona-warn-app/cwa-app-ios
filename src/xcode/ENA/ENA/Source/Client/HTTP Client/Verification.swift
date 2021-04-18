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
	
	init(key provider: PublicKeyProviding = PublicKeyProvider()) {
		pkProvider = provider
	}

	// MARK: - Protocol SignatureVerification
	
	func verify(_ package: SAPDownloadedPackage) -> Bool {
		do {
			let parsedSignatureFile = try SAP_External_Exposurenotification_TEKSignatureList(serializedData: package.signature)
			
			for signatureEntry in parsedSignatureFile.signatures {
				let signatureData: Data = signatureEntry.signature
				let signature = try ECDSASignature(derRepresentation: signatureData)
				if pkProvider.currentPublicSignatureKey().isValid(signature: signature, for: package.bin) {
					return true
				}
			}

			return false // no match at all
		} catch {
			Log.error("Package verification error! \(error.localizedDescription)", log: .crypto, error: error)
			return false
		}
	}

	func callAsFunction(_ package: SAPDownloadedPackage) -> Bool {
		verify(package)
	}
	
	// MARK: - Private
	
	private let pkProvider: PublicKeyProviding
}
