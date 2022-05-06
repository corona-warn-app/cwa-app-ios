//
// 🦠 Corona-Warn-App
//

struct DigitalCovid19CertificateSendModel: PaddingResource {

	// MARK: - Init

	init(
		registrationToken: String
	) {
		self.registrationToken = registrationToken
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""

	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let registrationToken: String

}
