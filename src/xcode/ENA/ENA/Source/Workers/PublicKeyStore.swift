//
// 🦠 Corona-Warn-App
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

enum KeyError: Error {
	/// It was not possible to create the base64 encoded data from the public key string
	case encodingError
	/// It was not possible to map the provided bundleID to a matching public key
	case environmentError
	/// It was not possible to read the plist containing the public keys
	case plistError
}

extension Data {
	init(staticBase64Encoded: StaticString) {
		// swiftlint:disable:next force_unwrapping
		self.init(base64Encoded: "\(staticBase64Encoded)")!
	}
}

enum PublicKeyEnv {
	case production
	case development

	/// Returns the string representation of the PK.
	/// Note that the values are taken from the regular PK in PEM format but without the first 36 characters,
	/// which denote PEM header information. These 36 characters are typically:
	/// `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE`
	///
	/// We don't want to rely on `rawValue` but make accessing the key an explicit action.
	var stringRepresentation: StaticString {
		switch self {
		case .production: return "c7DEstcUIRcyk35OYDJ95/hTg3UVhsaDXKT0zK7NhHPXoyzipEnOp3GyNXDVpaPi3cAfQmxeuFMZAIX2+6A5Xg=="
		case .development: return "3BYTxr2HuJYQG+d7Ezu6KS8GEbFkiEvyJFg0j+C839gTjT6j7Ho0EXXZ/a07ZfvKcC2cmc1SunsrqU9Jov1J5Q=="
		}
	}
}

typealias PublicKeyProviding = () -> PublicKeyProtocol
typealias PublicKeyFromStringProvider = (StaticString) -> PublicKeyProtocol
typealias PublicKeyProviderFromEnv = (PublicKeyEnv) -> PublicKeyProtocol

private let DefaultPublicKeyFromEnvProvider: PublicKeyProviderFromEnv = { env in
	return DefaultPublicKeyFromString(env.stringRepresentation)
}

let DefaultPublicKeyFromString: PublicKeyFromStringProvider = { string -> PublicKeyProtocol in
	if #available(iOS 13.0, *) {
		let data = Data(staticBase64Encoded: string)
		guard let key = try? P256.Signing.PublicKey(rawRepresentation: data) else {
			fatalError("Could not initialize private key from given data")
		}
		return key
	} else {
		return PublicKey(with: string)
	}
}

let DefaultPublicKeyProvider: PublicKeyProviding = {
	#if USE_DEV_PK_FOR_SIG_VERIFICATION
	return {
		DefaultPublicKeyFromEnvProvider(.development)
	}
	#else
	return {
		DefaultPublicKeyFromEnvProvider(.production)
	}
	#endif
}()
