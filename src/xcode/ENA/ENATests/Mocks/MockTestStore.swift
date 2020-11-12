//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation

class MockTestStore: Store {
	func clearAll() {}

	var hasSeenSubmissionExposureTutorial: Bool = false

	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?

	var numberOfSuccesfulSubmissions: Int64?

	var initialSubmitCompleted: Bool = false

	var submitConsentAcceptTimestamp: Int64?

	var submitConsentAccept: Bool = false

	var isOnboarded: Bool = false

	var dateLastExposureDetection: Date?

	var dateOfAcceptedPrivacyNotice: Date?

	var allowsCellularUse: Bool = false

	var developerSubmissionBaseURLOverride: String?

	var developerDistributionBaseURLOverride: String?

	var developerVerificationBaseURLOverride: String?

	var teleTan: String?

	var tan: String?

	var testGUID: String?

	var devicePairingConsentAccept: Bool = false

	var devicePairingConsentAcceptTimestamp: Int64?

	var devicePairingSuccessfulTimestamp: Int64?

	var isAllowedToSubmitDiagnosisKeys: Bool = false

	var registrationToken: String?

	var allowRiskChangesNotification: Bool = true

	var allowTestsStatusNotification: Bool = true
}
