//
// 🦠 Corona-Warn-App
//

struct DCCPublicKeyRegistrationSendModel: PaddingResource {

	// MARK: - Init

	init(
		registrationToken: String,
		publicKey: String
	) {
		self.registrationToken = registrationToken
		self.publicKey = publicKey
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""

	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let registrationToken: String
	let publicKey: String

}
