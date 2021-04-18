//
// 🦠 Corona-Warn-App
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif


protocol PublicKeyProviding {
	func currentPublicSignatureKey() -> PublicKeyProtocol
}

struct PublicKeyProvider: PublicKeyProviding {

	func currentPublicSignatureKey() -> PublicKeyProtocol {
		let env = Environments().currentEnvironment()
		return publicKey(for: env)
	}

	func publicSignatureKey(for descriptor: EnvironmentDescriptor) -> PublicKeyProtocol? {
		let env = Environments().environment(descriptor)
		return publicKey(for: env)
	}

	private func publicKey(for environment: EnvironmentData) -> PublicKeyProtocol {
		do {
			// init public key
			if #available(iOS 13.0, *) {
				guard let data = Data(base64Encoded: environment.publicKeyString) else {
					fatalError("Could not initialize public key from given data")
				}
				return try P256.Signing.PublicKey(rawRepresentation: data)
			} else {
				return try PublicKey(with: environment.publicKeyString)
			}
		} catch {
			fatalError("Could not initialize public key: \(error.localizedDescription)")
		}
	}
}
