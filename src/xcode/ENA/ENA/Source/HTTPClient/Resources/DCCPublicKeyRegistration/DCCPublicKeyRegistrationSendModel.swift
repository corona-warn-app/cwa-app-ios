//
// 🦠 Corona-Warn-App
//

struct DCCPublicKeyRegistrationSendModel: PaddingResource {

	// MARK: - Init

	init(
		token: String,
		publicKey: String
	) {
		self.token = token
		self.publicKey = publicKey
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""

	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let token: String
	let publicKey: String

}
