//
// 🦠 Corona-Warn-App
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif


// DEV NOTE: structure might change ⚠️⚠️⚠️

// MARK: - HASH

extension Data {

	/// SHA 256 hash of the current Data
	/// - Returns: Data representation of the hash value
	func sha256() -> Data {
		if #available(iOS 13.0, *) {
			return Data(SHA256.hash(data: self))
		} else {
			preconditionFailure("not implemented")
		}
	}

	/// SHA 256 hash of the current Data
	/// - Returns: String representation of the hash value
	func sha256String() -> String {
		if #available(iOS 13.0, *) {
			// compact map removes 'SHA256 digest:' prefix
			return sha256().compactMap { String(format: "%02x", $0) }.joined()
		} else {
			preconditionFailure("not implemented")
		}
	}
}

// MARK: - Public Key Handling

protocol PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol
}

/// Very naïve implementation of `P256.Signing.PublicKey` used as data container.
struct PublicKey {
	let pemHeader: StaticString = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE"

	private let publicKey: String

	/// Initializes a PublicKey from a given key string.
	/// - Parameters:
	///   - pkString: A string representation of the public key to store
	///   - hasPrefix: Does the pkString provides a PEM header (`true`) or should it be attached during init (`false`). Defaults to `false`.
	init(with pkString: StaticString, hasPrefix: Bool = false) {
		self.publicKey = hasPrefix ? String(pkString) : String(pemHeader).appending(String(pkString))
	}
}

extension PublicKey: PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol {
		preconditionFailure("not implemented")
	}
}

@available(iOS 13.0, *)
extension P256.Signing.PublicKey: PublicKeyProvider {
	func isValidSignature<D>(_ signature: ECDSASignature, for data: D) -> Bool where D: DataProtocol {
		preconditionFailure("not implemented")
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
	var rawRepresentation: Data {
		preconditionFailure("not implemented")
	}

	var derRepresentation: Data {
		preconditionFailure("not implemented")
	}

	init<D>(rawRepresentation: D) throws where D: DataProtocol {
		preconditionFailure("not implemented")
	}

	init<D>(derRepresentation: D) throws where D: DataProtocol {
		preconditionFailure("not implemented")
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
