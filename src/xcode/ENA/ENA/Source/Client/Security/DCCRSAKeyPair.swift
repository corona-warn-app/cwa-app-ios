//
// 🦠 Corona-Warn-App
//

import Foundation

// MARK: - Digital COVID Certificate

enum DCCRSAKeyPairError: Error {
	case keyPairGenerationFailed(String)
	case keychainRetrievalFailed(String)
	case gettingDataRepresentationFailed(Error?)
	case encryptionFailed(Error?)
	case decryptionFailed(Error?)
}

struct DCCRSAKeyPair: Codable, Equatable {

	// MARK: - Init

	init(registrationToken: String) throws {
		self.registrationToken = registrationToken

		let privateKeyStatus = SecItemCopyMatching(query(for: privateKeyTag), nil)
		let publicKeyStatus = SecItemCopyMatching(query(for: publicKeyTag), nil)

		if privateKeyStatus == noErr && publicKeyStatus == noErr {
			// Keys were already generated
			return
		}

		let status = SecKeyGeneratePair(keyPairAttr, nil, nil)

		guard status == noErr else {
			let errorText = String(describing: status)
			Log.error("Error generating DGC RSA key pair: \(errorText)", log: .crypto)
			throw DCCRSAKeyPairError.keyPairGenerationFailed(errorText)
		}
	}

	// MARK: - Internal

	func privateKey() throws -> SecKey {
		var keychainItem: CFTypeRef?
		let status = SecItemCopyMatching(query(for: privateKeyTag), &keychainItem)

		guard status == noErr else {
			let errorText = String(describing: status)
			Log.error("Error retrieving private key from keychain: \(errorText)", log: .crypto)
			throw DCCRSAKeyPairError.keychainRetrievalFailed(errorText)
		}

		// swiftlint:disable:next force_cast
		return keychainItem as! SecKey
	}

	func publicKey() throws -> SecKey {
		var keychainItem: CFTypeRef?
		let status = SecItemCopyMatching(query(for: publicKeyTag), &keychainItem)

		guard status == noErr else {
			let errorText = String(describing: status)
			Log.error("Error retrieving public key from keychain: \(errorText)", log: .crypto)
			throw DCCRSAKeyPairError.keychainRetrievalFailed(errorText)
		}

		// swiftlint:disable:next force_cast
		return keychainItem as! SecKey
	}
	
	/// The publicKey with added RSA Header and Base64 encoded
	func publicKeyForBackend() throws -> String {
		var error: Unmanaged<CFError>?
		guard let publicKeyData = SecKeyCopyExternalRepresentation(try publicKey(), &error) as Data? else {
			throw DCCRSAKeyPairError.gettingDataRepresentationFailed(error?.takeUnretainedValue())
		}

		let publicKeyWithRSAHeader = Data([
			0x30, 0x82, 0x01, 0xA2,
			0x30, 0x0D,
			0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
			0x05, 0x00,
			0x03, 0x82, 0x01, 0x8F, 0x00
		]) + publicKeyData

		return publicKeyWithRSAHeader.base64EncodedString()
	}

	func encrypt(_ plainText: Data) throws -> Data {
		var error: Unmanaged<CFError>?

		guard let cipherText = SecKeyCreateEncryptedData(try publicKey(), .rsaEncryptionOAEPSHA256, plainText as CFData, &error) as Data? as Data? else {
			Log.error("RSA encryption failed: \(String(describing: (error as? Error)?.localizedDescription))", log: .crypto)
			throw DCCRSAKeyPairError.encryptionFailed(error?.takeUnretainedValue())
		}

		return cipherText
	}

	func decrypt(_ cipherText: Data) throws -> Data {
		var error: Unmanaged<CFError>?
		guard let clearText = SecKeyCreateDecryptedData(try privateKey(), .rsaEncryptionOAEPSHA256, cipherText as CFData, &error) as Data? else {
			Log.error("RSA decryption failed: \(String(describing: (error as? Error)?.localizedDescription))", log: .crypto)
			throw DCCRSAKeyPairError.decryptionFailed(error?.takeUnretainedValue())
		}

		return clearText
	}

	func removeFromKeychain() {
		SecItemDelete(query(for: privateKeyTag))
		SecItemDelete(query(for: publicKeyTag))
	}

	// MARK: - Private

	private let registrationToken: String
	
	private var privateKeyTag: Data {
		"de.rki.coronawarnapp.dcc.\(registrationToken).private".data(using: String.Encoding.utf8) ?? Data()
	}

	private var publicKeyTag: Data {
		"de.rki.coronawarnapp.dcc.\(registrationToken).public".data(using: String.Encoding.utf8) ?? Data()
	}

	private var keyPairAttr: CFDictionary {
		let publicKeyAttr: [NSObject: NSObject] = [
			kSecAttrIsPermanent: true as NSObject,
			kSecAttrApplicationTag: publicKeyTag as NSObject,
			kSecClass: kSecClassKey,
			kSecReturnData: kCFBooleanTrue
		]

		let privateKeyAttr: [NSObject: NSObject] = [
			kSecAttrIsPermanent: true as NSObject,
			kSecAttrApplicationTag: privateKeyTag as NSObject,
			kSecClass: kSecClassKey,
			kSecReturnData: kCFBooleanTrue
		]

		var keyPairAttr = [NSObject: NSObject]()
		keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
		keyPairAttr[kSecAttrKeySizeInBits] = 3072 as NSObject
		keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
		keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject

		return keyPairAttr as CFDictionary
	}

	private func query(for tag: Data) -> CFDictionary {
		let query: [String: Any] = [
			kSecClass as String: kSecClassKey,
			kSecAttrApplicationTag as String: tag,
			kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
			kSecReturnRef as String: true
		]

		return query as CFDictionary
	}

}
