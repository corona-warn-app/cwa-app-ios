////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct MockPublicKeyProvider: PublicKeyProviding {

	private let signingKey: PrivateKeyProvider

	init(signingKey: PrivateKeyProvider) {
		self.signingKey = signingKey
	}

	var currentPublicSignatureKey: PublicKeyProtocol {
		CryptoProvider.createPublicKey(from: signingKey)
	}
}
