//
// 🦠 Corona-Warn-App
//

import UIKit
#if canImport(CryptoKit)
import CryptoKit
#endif


protocol PublicKeyProviding {
	var currentPublicSignatureKey: PublicKeyProtocol { get }
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

	var currentPublicSignatureKey: PublicKeyProtocol {
		let env = store.selectedServerEnvironment
		do {
			// init public key
			if #available(iOS 13.0, *) {
				guard let data = Data(base64Encoded: env.publicKeyString) else {
					fatalError("Could not initialize public key from given data")
				}
				return try P256.Signing.PublicKey(rawRepresentation: data)
			} else {
				return try PublicKey(with: env.publicKeyString)
			}
		} catch {
			fatalError("Could not initialize public key: \(error.localizedDescription)")
		}
	}
}
