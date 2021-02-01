////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPACServiceMock: PrivacyPreservingAccessControl {

	init() {
		guard let randomData = UUID().uuidString.data(using: .utf8) else {
			fatalError("Failed to create test data")
		}
		self.ppacToken = PPACToken(
			apiToken: UUID().uuidString,
			deviceToken: randomData.base64EncodedString()
		)
	}

	// MARK: - Protocol PrivacyPreservingAccessControl

	func getPPACToken(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		completion(.success(ppacToken))
	}

	private let ppacToken: PPACToken

}
