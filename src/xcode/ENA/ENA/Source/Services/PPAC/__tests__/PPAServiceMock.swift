////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class PPAServiceMock: PPACService {

	// MARK: - Protocol PrivacyPreservingAccessControl

	override func getPPACToken(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		guard let randomData = UUID().uuidString.data(using: .utf8) else {
			fatalError("Failed to create test data")
		}
		let ppacToken = PPACToken(
			apiToken: apiToken.token,
			deviceToken: randomData.base64EncodedString()
		)
		completion(.success(ppacToken))	}

	// MARK: - Private

}
