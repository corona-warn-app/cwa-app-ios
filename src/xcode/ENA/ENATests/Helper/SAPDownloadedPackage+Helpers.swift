//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import CryptoKit
import ZIPFoundation

// MARK: - Static helpers for package creation

extension SAPDownloadedPackage {

	/// - note: Will SHA256 hash the data
	static func makeSignature(data: Data, key: PrivateKeyProvider, bundleId: String = "de.rki.coronawarnapp") throws -> SAP_External_Exposurenotification_TEKSignature {
		var signature = SAP_External_Exposurenotification_TEKSignature()
		signature.signature = try key.signature(for: data).derRepresentation
		signature.signatureInfo = makeSignatureInfo(bundleId: bundleId)

		return signature
	}

	static func makeSignatureInfo(bundleId: String = "de.rki.coronawarnapp") -> SAP_External_Exposurenotification_SignatureInfo {
		var info = SAP_External_Exposurenotification_SignatureInfo()
		info.appBundleID = bundleId

		return info
	}

	static func makePackage(bin: Data, signature: SAP_External_Exposurenotification_TEKSignatureList) throws -> SAPDownloadedPackage {
		return SAPDownloadedPackage(
			keysBin: bin,
			signature: try signature.serializedData()
		)
	}

	/// Make a SAPDownloadedPackage with the provided data and signing key
	///
	/// - important: Both data and key are defaulted, but make sure to pass your own key if you want to test the verification process!
	///	Accepting the default key is only useful if you just need a package and do not care about signing validation
	static func makePackage(bin: Data = Data(bytes: [0xA, 0xB, 0xC], count: 3), key: PrivateKeyProvider = CryptoProvider().createPrivateKey()) throws -> SAPDownloadedPackage {
		let signature = try makeSignature(data: bin, key: key).asList()
		return try makePackage(bin: bin, signature: signature)
	}
}

// MARK: - Helpers

extension SAPDownloadedPackage {
	func zipped() throws -> Archive {
		guard let archive = Archive(accessMode: .create) else { throw ArchivingError.creationError }

		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: UInt32(bin.count), bufferSize: 4, provider: { position, size -> Data in
			return bin.subdata(in: position..<position + size)
		})

		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: UInt32(signature.count), bufferSize: 4, provider: { position, size -> Data in
			return signature.subdata(in: position..<position + size)
		})

		return archive
	}
}

enum ArchivingError: Error {
	case creationError
}

extension SAP_External_Exposurenotification_TEKSignature {
	func asList() -> SAP_External_Exposurenotification_TEKSignatureList {
		var signatureList = SAP_External_Exposurenotification_TEKSignatureList()
		signatureList.signatures = [self]

		return signatureList
	}
}

extension Array where Element == SAP_External_Exposurenotification_TEKSignature {
	func asList() -> SAP_External_Exposurenotification_TEKSignatureList {
		var signatureList = SAP_External_Exposurenotification_TEKSignatureList()
		signatureList.signatures = self

		return signatureList
	}
}

/// Quick and dirty factory for asymmetric keys
struct CryptoProvider {

	/// Create a private signing key
	/// - Returns: The key as `PrivateKeyProvider`
	func createPrivateKey(useFallback: Bool = false) -> PrivateKeyProvider {
		if #available(iOS 13.0, *), !useFallback {
			return P256.Signing.PrivateKey()
		} else {
			preconditionFailure() // work in progress
		}
	}

	/// A public key
	///
	/// - Parameter privateKey: The private key to derive the public key from. If no key is given, the default private key will be created
	/// - Returns:The requested public key
	func createPublicKey(from privateKey: PrivateKeyProvider? = nil) -> PublicKeyProtocol {
		let priv = privateKey ?? createPrivateKey()
		return PublicKey(rawRepresentation: priv.publicKeyRaw)
	}

	/// Creates a new key pair
	///
	/// - Returns:A tuple containing a private key and it's corresponding public key
	func createKeyPair() -> (PrivateKeyProvider, PublicKeyProtocol) {
		let priv = createPrivateKey()
		return (priv, PublicKey(rawRepresentation: priv.publicKeyRaw))
	}
}
