//
// 🦠 Corona-Warn-App
//

struct RegistrationTokenSendModel: PaddingResource {

	// MARK: - Init

	init(
		token: String
	) {
		self.registrationToken = token
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""

	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let registrationToken: String
}
