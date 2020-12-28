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
	func sha256() -> Data {
		if #available(iOS 13.0, *) {
			return Data(SHA256.hash(data: self))
		} else {
			return sha256_fallback()
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
	func sha256_fallback() -> Data {
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

// MARK: - Public Key Handling

protocol PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol
}

/// Very naïve implementation of `P256.Signing.PublicKey` used as data container.
struct PublicKey {
	let pemHeader: StaticString = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE"
	let pemRepresentation: String
	let rawRepresentation: Data

	/// Initializes a PublicKey from a given key string.
	/// - Parameters:
	///   - pkString: A string representation of the public key to store
	///   - hasPrefix: Does the pkString provides a PEM header (`true`) or should it be attached during init (`false`). Defaults to `false`.
	init(with pkString: StaticString, hasPrefix: Bool = false) {
		self.pemRepresentation = hasPrefix ? String(pkString) : String(pemHeader).appending(String(pkString))
		guard let raw = pemRepresentation.data(using: .utf8) else {
			fatalError("Cannot initialize raw representation of public key")
		}
		self.rawRepresentation = raw
	}
}

extension PublicKey: PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol {
		#warning("invalid mock implementation")
		return true
	}
}

@available(iOS 13.0, *)
extension P256.Signing.PublicKey: PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol {
		#warning("invalid mock implementation")
		return true
	}
}

// MARK: - ECDSA Signature Handling

/// Umrella protocol to cover CryptoKit's `P256.Signing.ECDSASignature` and custom `ECDSASignature`.
protocol ECDSASignatureProtocol {
	/// Returns the raw signature.
	/// The raw signature format for ECDSA is r || s
	var rawRepresentation: Data { get }

	/// A DER-encoded representation of the signature
	var derRepresentation: Data { get }

	/// Initializes ECDSASignature from the raw representation.
	/// The raw signature format for ECDSA is r || s
	/// As defined in https://tools.ietf.org/html/rfc4754
	init<D>(rawRepresentation: D) throws where D: DataProtocol

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

/// Very naïve implementation of `P256.Signing.ECDSASignature` used as data container.
struct ECDSASignature: ECDSASignatureProtocol {
	var rawRepresentation: Data

	var derRepresentation: Data

	init<D>(rawRepresentation: D) throws where D: DataProtocol {
		var representation: Data = Data()
		_ = representation.withUnsafeMutableBytes { rawRepresentation.copyBytes(to: $0) }

		self.rawRepresentation = representation
		#warning("work in progress")
		self.derRepresentation = Data() // self.rawRepresentation
	}

	init<D>(derRepresentation: D) throws where D: DataProtocol {
		var representation: Data = Data()
		_ = representation.withUnsafeMutableBytes { derRepresentation.copyBytes(to: $0) }

		self.derRepresentation = representation
		#warning("work in progress")
		self.rawRepresentation = Data() // self.derRepresentation
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
