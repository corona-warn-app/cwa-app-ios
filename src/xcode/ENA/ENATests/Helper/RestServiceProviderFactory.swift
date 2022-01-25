//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

#if DEBUG

extension RestServiceProviding where Self == RestServiceProviderStub {

	static var exposureSubmissionServiceProvider: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationReceiveModel(submissionTAN: "registrationToken")
			)
		])
	}

	static var coronaTestServiceProvider: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(
				RegistrationReceiveModel(submissionTAN: "registrationToken")
			)
		])
	}

	static var onBehalfCheckinSubmissionServiceProviderStub: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(
				RegistrationReceiveModel(submissionTAN: "registrationToken")
			)
		])
	}
}

#endif
