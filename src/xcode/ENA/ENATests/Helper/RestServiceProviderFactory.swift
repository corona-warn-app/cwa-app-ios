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
				SubmissionTANModel(submissionTAN: "registrationToken")
			)
		])
	}

	static var coronaTestServiceProvider: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(
				SubmissionTANModel(submissionTAN: "registrationToken")
			)
		])
	}

	static var onBehalfCheckinSubmissionServiceProviderStub: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(
				SubmissionTANModel(submissionTAN: "registrationToken")
			)
		])
	}
}

#endif
