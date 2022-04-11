//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

enum UITestingParameters {
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
	
	init?(stringValue: String, coronaTestType: CoronaTestType) {
		guard let rawValue = Int(stringValue) else {
			fatalError("Could not convert String to Int")
		}
		
		self.init(serverResponse: rawValue, coronaTestType: coronaTestType)
	}
}
