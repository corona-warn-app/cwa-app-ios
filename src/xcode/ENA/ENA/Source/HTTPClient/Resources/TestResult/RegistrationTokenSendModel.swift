//
// 🦠 Corona-Warn-App
//
import Foundation

/// You might wonder why there is an extra RegistrationToken model for sending, its needed since while sending we have to pad the Resource
struct RegistrationTokenSendModel: PaddingResource {

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
