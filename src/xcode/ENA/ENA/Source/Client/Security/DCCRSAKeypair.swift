//
// 🦠 Corona-Warn-App
//

import Foundation

// MARK: - Digital COVID Certificate

struct DCCRSAKeyPair: Codable {

	// MARK: - Init

	init() throws {
		var _publicKey: SecKey?
		var _privateKey: SecKey?

		let statusCode = SecKeyGeneratePair(DCCRSAKeyPair.keyPairAttr, &_publicKey, &_privateKey)

		guard statusCode == noErr, let publicKey = _publicKey, let privateKey = _privateKey else {
			let errorText = String(describing: statusCode)
			Log.error("Error generating DGC RSA key pair: \(errorText)", log: .crypto)
			throw DCCRSAKeyPairError.keyPairGeneration(errorText)
		}
		self.privateKey = privateKey
		self.publicKey = publicKey

		var error: Unmanaged<CFError>?
		guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
			throw DCCRSAKeyPairError.publicKey(error?.takeUnretainedValue())
		}
		let publicKeyWithRSAHeader = Data([
			0x30, 0x82, 0x01, 0xA2,
			0x30, 0x0D,
			0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
			0x05, 0x00,
			0x03, 0x82, 0x01, 0x8F, 0x00
		]) + publicKeyData
		self.publicKeyForBackend = publicKeyWithRSAHeader.base64EncodedString()
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case publicKey
		case privateKey
		case publicKeyForBackend
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let publicKeyData = try container.decode(Data.self, forKey: .publicKey)
		let privateKeyData = try container.decode(Data.self, forKey: .privateKey)

		var error: Unmanaged<CFError>?
		guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, DCCRSAKeyPair.keyPairAttr, &error),
			  let privateKey = SecKeyCreateWithData(privateKeyData as CFData, DCCRSAKeyPair.keyPairAttr, &error) else {
			Log.error("RSA key pair decoding failed: \(String(describing: (error as? Error)?.localizedDescription))", log: .crypto)
			throw DCCRSAKeyPairError.decoding(error?.takeUnretainedValue())
		}

		self.publicKey = publicKey
		self.privateKey = privateKey

		publicKeyForBackend = try container.decode(String.self, forKey: .publicKeyForBackend)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		var error: Unmanaged<CFError>?
		guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?,
			  let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
			Log.error("RSA key pair encoding failed: \(String(describing: (error as? Error)?.localizedDescription))", log: .crypto)
			throw DCCRSAKeyPairError.encoding(error?.takeUnretainedValue())
		}

		try container.encode(publicKeyData, forKey: .publicKey)
		try container.encode(privateKeyData, forKey: .privateKey)
		try container.encode(publicKeyForBackend, forKey: .publicKeyForBackend)
	}

	// MARK: - Internal
	
	enum DCCRSAKeyPairError: Error {
		case keyPairGeneration(String)	// Key generation failed
		case publicKey(Error?) // Unable to get public key representation
		case encoding(Error?) // Encoding failed
		case decoding(Error?) // Decoding failed
		case decryption(Error?) // Decoding failed
	}
	
	let publicKey: SecKey
	let privateKey: SecKey
	
	/// The publicKey with added RSA Header and Base64 encoded
	let publicKeyForBackend: String

	func decrypt(_ cipherText: Data) throws -> Data {
		var error: Unmanaged<CFError>?
		guard let clearText = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, cipherText as CFData, &error) as Data? else {
			Log.error("RSA decryption failed: \(String(describing: (error as? Error)?.localizedDescription))", log: .crypto)
			throw DCCRSAKeyPairError.encoding(error?.takeUnretainedValue())
		}

		return clearText
	}

	// MARK: - Private

	private static let keyPairAttr: CFDictionary = {
		let tag = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"

		let publicKeyAttr: [NSObject: NSObject] = [
			kSecAttrIsPermanent: true as NSObject,
			kSecAttrApplicationTag: ("\(tag).dgc.public".data(using: String.Encoding.utf8) ?? Data()) as NSObject,
			kSecClass: kSecClassKey,
			kSecReturnData: kCFBooleanTrue]

		let privateKeyAttr: [NSObject: NSObject] = [
			kSecAttrIsPermanent: true as NSObject,
			kSecAttrApplicationTag: ("\(tag).dgc.private".data(using: String.Encoding.utf8) ?? Data()) as NSObject,
			kSecClass: kSecClassKey,
			kSecReturnData: kCFBooleanTrue]

		var keyPairAttr = [NSObject: NSObject]()
		keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
		keyPairAttr[kSecAttrKeySizeInBits] = 3072 as NSObject
		keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
		keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject

		return keyPairAttr as CFDictionary
	}()

}
