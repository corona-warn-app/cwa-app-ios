//
// 🦠 Corona-Warn-App
//

import UIKit
#if canImport(CryptoKit)
import CryptoKit
#endif


protocol PublicKeyProviding {
	func currentPublicSignatureKey() -> PublicKeyProtocol
}

struct PublicKeyProvider: PublicKeyProviding {
	let store: ServerEnvironmentProviding

	init(store: ServerEnvironmentProviding? = nil) {
		if let store = store {
			self.store = store
		} else {
			let appDelegate = UIApplication.shared.delegate as? CoronaWarnAppDelegate ?? AppDelegate()
			self.store = appDelegate.store
		}
	}

	func currentPublicSignatureKey() -> PublicKeyProtocol {
		let env = store.selectedServerEnvironment
		return publicKey(for: env)
	}

	func publicSignatureKey(for descriptor: EnvironmentDescriptor) -> PublicKeyProtocol? {
		let env = ServerEnvironment().environment(descriptor)
		return publicKey(for: env)
	}

	private func publicKey(for environment: ServerEnvironmentData) -> PublicKeyProtocol {
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
