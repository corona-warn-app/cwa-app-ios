////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class TestDummyPPAnalyticsDataImplementation: PPAnalyticsData {
	
	var lastSubmissionAnalytics: Date?
	var lastAppReset: Date?
	var lastSubmittedPPAData: String?
	var submittedWithQR: Bool = false
	var currentRiskExposureMetadata: RiskExposureMetadata?
	var previousRiskExposureMetadata: RiskExposureMetadata?
	var userMetadata: UserMetadata?
	var clientMetadata: ClientMetadata?
	var keySubmissionMetadata: KeySubmissionMetadata?
	var testResultMetadata: TestResultMetadata?
	var exposureWindowsMetadata: ExposureWindowsMetadata?
}
