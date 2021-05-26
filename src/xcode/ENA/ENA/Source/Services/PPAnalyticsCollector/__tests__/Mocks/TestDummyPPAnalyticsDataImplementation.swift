////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class TestDummyPPAnalyticsDataImplementation: PPAnalyticsData {
	
	var lastSubmissionAnalytics: Date?
	var lastAppReset: Date?
	var lastSubmittedPPAData: String?
	var currentRiskExposureMetadata: RiskExposureMetadata?
	var previousRiskExposureMetadata: RiskExposureMetadata?
	var userMetadata: UserMetadata?
	var clientMetadata: ClientMetadata?
	var pcrKeySubmissionMetadata: KeySubmissionMetadata?
	var antigenKeySubmissionMetadata: KeySubmissionMetadata?
	var testResultMetadata: TestResultMetadata?
	var antigenTestResultMetadata: TestResultMetadata?
	var exposureWindowsMetadata: ExposureWindowsMetadata?
}
