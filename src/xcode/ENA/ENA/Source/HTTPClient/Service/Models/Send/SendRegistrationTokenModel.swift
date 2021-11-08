//
// 🦠 Corona-Warn-App
//

import Foundation

struct SendRegistrationTokenModel: PaddingResource {

	// MARK: - Init

	init(
		token: String
	) {
		self.tokenString = token
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""


	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let tokenString: String
}
