//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

enum UITestingParameters {
	enum ExposureSubmission: String {
		case useMock = "UI:ExposureSubmission:useMock"
		case getRegistrationTokenSuccess = "UI:ExposureSubmission:getRegistrationTokenSuccess"
		case loadSupportedCountriesSuccess = "UI:ExposureSubmission:loadSupportedCountriesSuccess"
		case getTemporaryExposureKeysSuccess = "UI:ExposureSubmission:getTemporaryExposureKeysSuccess"
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

extension TestResult {
	// MARK: - Init
	
	init?(stringValue: String) {
		guard let rawValue = Int(stringValue) else {
			fatalError("Could not convert String to Int")
		}
		
		self.init(rawValue: rawValue)
	}
	
	var stringValue: String {
		String(describing: self.rawValue)
	}
}
