//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData
	) {
		self.initializationData = initializationData
	}

	var initializationData: TicketValidationInitializationData

	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {

	}

	func grantFirstConsent(
		completion: @escaping (Result<ValidationConditions, TicketValidationError>) -> Void
	) {

	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {

	}

	func validate(
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
	) {

	}

	func cancel() {

	}
	
	func encryptAndSignDCC(
		dccBarcodeData: String,
		nonceBase64: String,
		encryptionScheme: EncryptionScheme,
		publicKeyForEncryption: SecKey,
		privateKeyForSigning: SecKey
	) -> Result<EncryptAndSignResult, EncryptAndSignError> {
		
		// Determine iv (initializationVector): the iv shall be derived as the byte sequence (Data / ByteArray) of nonceBase64 using base64 encoding.
		guard let initializationVector = Data(base64Encoded: nonceBase64) else {
			return .failure(.UNKNOWN)
		}
		
		// Determine plaintext: the plaintext shall be derived as the byte sequence (Data / ByteArray) of dccBarcodeData using UTF-8 encoding.
		guard let plaintext = dccBarcodeData.data(using: .utf8) else {
			return .failure(.UNKNOWN)
		}
		
		// Generate key: the key shall be generated as a secure random byte sequence (Data / ByteArray) of 32 bytes
		guard let key = Data.randomBytes(length: 32) else {
			return .failure(.UNKNOWN)
		}
		
		// Encrypt DCC as encryptedDCC
		let encryptedDCC: Data
		
		switch encryptionScheme {
		case .RSAOAEPWithSHA256AESCBC:
			let cbcEncryption = CBCEncryption(
				encryptionKey: key,
				initializationVector: initializationVector,
				ivLengthConstraint: 16
			)
			switch cbcEncryption.encrypt(data: plaintext) {
			case .success(let encryptedData):
				encryptedDCC = encryptedData
			case .failure(let error):
				return .failure(.AES_CBC_ERROR(error))
			}
		case .RSAOAEPWithSHA256AESGCM:
			let gcmEncryption = GCMEncryption(
				encryptionKey: key,
				initializationVector: initializationVector,
				ivLengthConstraint: 16
			)
			switch gcmEncryption.encrypt(data: plaintext) {
			case .success(let encryptedData):
				encryptedDCC = encryptedData
			case .failure(let error):
				return .failure(.AES_GCM_ERROR(error))
			}
		}
		
		// Encrypt key as encryptionKey
		let encryptionKey: Data
		switch RSAEncryption().encrypt(key, publicKey: publicKeyForEncryption) {
		case .success(let encryptedData):
			encryptionKey = encryptedData
		case .failure(let error):
			return .failure(.RSA_ENC_ERROR(error))
		}
		
		// Sign ciphertext
		let signer = ECSHA256Signer(
			privateKey: privateKeyForSigning,
			data: encryptedDCC
		)
		
		let signature: Data
		switch signer.sign() {
		case .success(let signedData):
			signature = signedData
		case .failure(let error):
			return .failure(.EC_SIGN_ERROR(error))
		}
		
		// Determine encryptedDCCBase64: the encryptedDCCBase64 shall be derived as the base64-encoded string of encryptedDCC
		// Determine encryptionKeyBase64: the encryptionKeyBase64 shall be derived as the base64-encoded string of encryptionKey
		// Determine signatureBase64: the signatureBase64 shall be derived as the base64-encoded string of signature
		// Determine signatureAlgorithm: the signatureAlgorithm shall be set to the string SHA256withECDSA
		return .success(EncryptAndSignResult(
			encryptedDCCBase64: encryptedDCC.base64EncodedString(),
			encryptionKeyBase64: encryptionKey.base64EncodedString(),
			signatureBase64: signature.base64EncodedString(),
			signatureAlgorithm: "SHA256withECDSA"
		))
	}
}
