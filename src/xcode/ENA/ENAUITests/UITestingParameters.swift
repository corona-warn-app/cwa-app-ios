//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

enum UITestingParameters {
	enum ExposureSubmission: String {
		case useMock = "UI:ExposureSubmission:useMock"
		case getRegistrationTokenSuccess = "UI:ExposureSubmission:getRegistrationTokenSuccess"
		case submitExposureSuccess = "UI:ExposureSubmission:submitExposureSuccess"
	}

	enum SecureStoreHandling: String {
		case simulateMismatchingKey = "UI:SecureStoreHandling:simulateMismatchingKey"
	}
}

extension ENStatus {
	var stringValue: String {
		String(describing: self.rawValue)
	}
}
