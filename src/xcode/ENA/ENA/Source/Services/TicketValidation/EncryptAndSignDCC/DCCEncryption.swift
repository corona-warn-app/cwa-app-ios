//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class DCCEncryption {
	
	func encryptAndSignDCC(
		dccBarcodeData: String,
		nonceBase64: String,
		encryptionScheme: EncryptionScheme,
		publicKeyForEncryption: SecKey,
		privateKeyForSigning: SecKey
	) -> Result<EncryptAndSignResult, EncryptAndSignError> {
		Log.info("Encrypt and sign DCC.", log: .ticketValidation)

		// Determine iv (initializationVector): the iv shall be derived as the byte sequence (Data / ByteArray) of nonceBase64 using base64 encoding.
		guard let initializationVector = Data(base64Encoded: nonceBase64) else {
			Log.error("Failed to decode initializationVector.", log: .ticketValidation)
			return .failure(.UNKNOWN)
		}
		
		// Determine plaintext: the plaintext shall be derived as the byte sequence (Data / ByteArray) of dccBarcodeData using UTF-8 encoding.
		guard let plaintext = dccBarcodeData.data(using: .utf8) else {
			Log.error("Failed to decode dccBarcodeData.", log: .ticketValidation)
			return .failure(.UNKNOWN)
		}
		
		// Generate key: the key shall be generated as a secure random byte sequence (Data / ByteArray) of 32 bytes
		guard let key = Data.randomBytes(length: 32) else {
			Log.error("Failed to generate randow data.", log: .ticketValidation)
			return .failure(.UNKNOWN)
		}
		
		// Encrypt DCC as encryptedDCC
		Log.debug("Encrypt DCC as encryptedDCC.", log: .ticketValidation)
		let encryptDCCResult = encrypt(
			dcc: plaintext,
			key: key,
			initializationVector: initializationVector,
			encryptionScheme: encryptionScheme
		)
		
		let encryptedDCC: Data
		switch encryptDCCResult {
		case .success(let encryptedData):
			encryptedDCC = encryptedData
		case .failure(let error):
			return .failure(error)
		}
		
		// Encrypt key as encryptionKey
		Log.debug("Encrypt key as encryptionKey.", log: .ticketValidation)
		let encryptionKey: Data
		switch RSAEncryption().encrypt(key, publicKey: publicKeyForEncryption) {
		case .success(let encryptedData):
			encryptionKey = encryptedData
		case .failure(let error):
			return .failure(.RSA_ENC_ERROR(error))
		}
		
		// Sign ciphertext
		Log.debug("Sign ciphertext.", log: .ticketValidation)
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
		
		Log.debug("Finished encrypting and signing DCC.", log: .ticketValidation)
		return .success(EncryptAndSignResult(
			encryptedDCCBase64: encryptedDCC.base64EncodedString(),
			encryptionKeyBase64: encryptionKey.base64EncodedString(),
			signatureBase64: signature.base64EncodedString(),
			signatureAlgorithm: "SHA256withECDSA"
		))
	}
	
	private func encrypt(
		dcc: Data,
		key: Data,
		initializationVector: Data,
		encryptionScheme: EncryptionScheme
	) -> Result<Data, EncryptAndSignError> {
	
		switch encryptionScheme {
		case .RSAOAEPWithSHA256AESCBC:
			let cbcEncryption = CBCEncryption(
				encryptionKey: key,
				initializationVector: initializationVector,
				ivLengthConstraint: 16
			)
			switch cbcEncryption.encrypt(data: dcc) {
			case .success(let encryptedData):
				return .success(encryptedData)
			case .failure(let error):
				return .failure(.AES_CBC_ERROR(error))
			}
		case .RSAOAEPWithSHA256AESGCM:
			let gcmEncryption = GCMEncryption(
				encryptionKey: key,
				initializationVector: initializationVector,
				ivLengthConstraint: 16
			)
			switch gcmEncryption.encrypt(data: dcc) {
			case .success(let encryptedData):
				return .success(encryptedData)
			case .failure(let error):
				return .failure(.AES_GCM_ERROR(error))
			}
		}
	}
	
}
