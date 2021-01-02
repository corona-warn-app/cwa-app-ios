//
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif


// MARK: - HASH

extension Data {

	/// SHA 256 hash of the current Data
	/// - Returns: Data representation of the hash value
	func sha256(enforceFallback: Bool = false) -> Data {
		if #available(iOS 13.0, *), !enforceFallback {
			return Data(SHA256.hash(data: self))
		} else {
			return sha256fallback()
		}
	}

	/// SHA 256 hash of the current Data
	/// - Returns: String representation of the hash value
	func sha256String() -> String {
		sha256().compactMap { String(format: "%02x", $0) }.joined()
	}


	/// Explicit fallback implementation for pre-iOS13 builds.
	///
	/// Don't use this directly and `sha256()` instead.
	///
	/// - Returns: Data representation of the hash value
	private func sha256fallback() -> Data {
		// via https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5

		// #define CC_SHA256_DIGEST_LENGTH     32
		// Creates an array of unsigned 8 bit integers that contains 32 zeros
		var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

		// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
		// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
		_ = self.withUnsafeBytes {
			// CommonCrypto
			// extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
			// OpenSSL                                                                             |
			// unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
			CC_SHA256($0.baseAddress, UInt32(self.count), &digest)
		}

		return Data(digest)
	}
}

// ------ 8< cut here -------

// MARK: - Asymmetric Key Handling

protocol PrivateKeyProvider {
	var privateKeyRaw: Data { get }
	var publicKeyRaw: Data { get }

	func signature(for data: Data) throws -> ECDSASignatureProtocol
}

@available(iOS 13.0, *)
extension P256.Signing.PrivateKey: PrivateKeyProvider {
	var privateKeyRaw: Data {
		return self.rawRepresentation
	}

	var publicKeyRaw: Data {
		return self.publicKey.rawRepresentation
	}

	func signature(for data: Data) throws -> ECDSASignatureProtocol {
		// type cast to enforce CryptoKit's `signature(for:)`
		return try self.signature(for: data) as P256.Signing.ECDSASignature
	}
}

struct PrivateKey {

	/// The corresponding public key.
	var publicKey: PublicKey {
		let publicKey = SecKeyCopyPublicKey(privateKey)
		var error: Unmanaged<CFError>?

		// swiftlint:disable force_unwrapping
		guard let cfdata = SecKeyCopyExternalRepresentation(publicKey!, &error) else {
			let err = error!.takeRetainedValue() as Error
			fatalError(err.localizedDescription)
		}
		// swiftlint:enable force_unwrapping
		return PublicKey(rawRepresentation: cfdata as Data)
	}

	/// Our defaul tag for all keys
	private let defaultBundleId = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"

	/// Internal reference to the 'real' key
	private let privateKey: SecKey

	/// Generates a new private key with a SHA-256 ECDSA algorithm.
	///
	/// - Parameter tag: Consider this an identifier. Defaults to the main bundle identifier if present or "de.rki.coronawarnapp"
	init(tag: String = (Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp")) throws {
		let attributes: [String: Any] =
			[kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom, // https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_attribute_keys_and_values#1679067
			 kSecAttrKeySizeInBits as String: 256,
			 kSecPrivateKeyAttrs as String: [
				kSecAttrIsPermanent as String: true,
				kSecAttrApplicationTag as String: tag
			 ]
		]

		var error: Unmanaged<CFError>?
		guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
			// swiftlint:disable:next force_unwrapping
			throw error!.takeRetainedValue() as Error // ok for now
		}
		self.privateKey = privateKey
	}
}

extension PrivateKey: PrivateKeyProvider {
	var privateKeyRaw: Data {
		var error: Unmanaged<CFError>?
		guard let cfdata = SecKeyCopyExternalRepresentation(privateKey, &error) else {
			// swiftlint:disable:next force_unwrapping
			let err = error!.takeRetainedValue() as Error
			fatalError(err.localizedDescription)
		}
		return cfdata as Data
	}

	var publicKeyRaw: Data {
		publicKey.rawRepresentation
	}

	func signature(for data: Data) throws -> ECDSASignatureProtocol {
		// as in `P256.Signing.ECDSASignature(derRepresentation: data)`
		return try ECDSASignature(derRepresentation: data)
	}


}

protocol PublicKeyProtocol {
	func isValid<D>(signature: ECDSASignatureProtocol, for data: D) -> Bool where D: DataProtocol
}

/// Very naïve implementation of `P256.Signing.PublicKey` used as data container.
struct PublicKey: PublicKeyProtocol {
	let rawRepresentation: Data

	/// Initializes a PublicKey from a given key string.
	/// - Parameters:
	///   - pkString: A string representation of the public key to store
	///   - hasPrefix: Does the pkString provides a PEM header (`true`) or should it be attached during init (`false`). Defaults to `false`.
	init(with pkString: StaticString, hasPrefix: Bool = false) {
		let rawData = Data(staticBase64Encoded: pkString)
		self.rawRepresentation = rawData
	}

	init(rawRepresentation: Data) {
		self.rawRepresentation = rawRepresentation
	}

	func isValid<D>(signature: ECDSASignatureProtocol, for data: D) -> Bool where D: DataProtocol {
		if #available(iOS 13, *) {
			// convert back to and use native CryptoKit data formats
			guard
				let key = try? P256.Signing.PublicKey(rawRepresentation: rawRepresentation),
				let sig = try? P256.Signing.ECDSASignature(derRepresentation: signature.derRepresentation) else {
				return false
			}
			return key.isValidSignature(sig, for: data)
		} else {
			preconditionFailure("to implement")
		}
	}
}

@available(iOS 13.0, *)
extension P256.Signing.PublicKey: PublicKeyProtocol {

	/// Simple wrapper to allow protocol conformance
	///
	///	Validation is done via CryptoKit's `isValid<D>` after parsing to native `P256.Signing.ECDSASignature`.
	///	The parsing/conversion might fail! Currently we just return `false` for the validation check. However,
	///	if this case happens, we might have a serious bug in the current implementation. Future implementations might change!
	///
	/// - Parameters:
	///   - signature: a `ECDSASignatureProtocol` to be parsed as a 'native' `P256.Signing.ECDSASignature`
	///   - data: the data to verify
	/// - Returns: true if signature and data match, false if not OR if the parsing fails
	func isValid<D>(signature: ECDSASignatureProtocol, for data: D) -> Bool where D: DataProtocol {
		guard let sig = try? P256.Signing.ECDSASignature(derRepresentation: signature.derRepresentation) else {
			Log.error("Cannot create P256.Signing.ECDSASignature from existing DER representation!", log: .localData)
			assertionFailure("we are not expecting this. check details!") // only triggered in DEBUG
			return false
		}
		return isValidSignature(sig, for: data)
	}
}

// MARK: - ECDSA Signature Handling

/// Umrella protocol to cover CryptoKit's `P256.Signing.ECDSASignature` and custom `ECDSASignature`.
protocol ECDSASignatureProtocol {

	/// A DER-encoded representation of the signature
	var derRepresentation: Data { get }

	/// Initializes ECDSASignature from the DER representation.
	init<D>(derRepresentation: D) throws where D: DataProtocol

	/// Calls the given closure with the contents of underlying storage.
	///
	/// - note: Calling `withUnsafeBytes` multiple times does not guarantee that
	///         the same buffer pointer will be passed in every time.
	/// - warning: The buffer argument to the body should not be stored or used
	///            outside of the lifetime of the call to the closure.
	func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

@available(iOS 13.0, *)
extension P256.Signing.ECDSASignature: ECDSASignatureProtocol {}

/// Very naïve implementation of `P256.Signing.ECDSASignature` used as data container.
struct ECDSASignature: ECDSASignatureProtocol {

	// X9.62 format (ASN.1 SEQUENCE of two INTEGER fields).
	var derRepresentation: Data

	/// Mimiking `P256.Signing.ECDSASignature.init(derRepresentation:)`
	/// - Parameter derRepresentation: DER format to store
	/// - Throws: Currently not happening in our custom implementation. We stick to `throws` to allow identical init signatures
	init<D>(derRepresentation: D) throws where D: DataProtocol {
		self.derRepresentation = Data(derRepresentation)
	}

	func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
		preconditionFailure("not implemented")
	}
}

// MARK: - General extensions

extension String {
	/// Initializes a `String` from `StaticString`.
	///
	/// Don't use `staticString.description`!
	/// See [https://stackoverflow.com/a/46403722/194585](https://stackoverflow.com/a/46403722/194585).
	init(_ staticString: StaticString) {
		self = staticString.withUTF8Buffer {
			String(decoding: $0, as: UTF8.self)
		}
	}
}
