//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

#if DEBUG

extension RestServiceProviding where Self == RestServiceProviderStub {

	static var coronaTestServiceProvider: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			)
		])
	}

	static var onBehalfCheckinSubmissionServiceProviderStub: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			)
		])
	}
}

#endif
