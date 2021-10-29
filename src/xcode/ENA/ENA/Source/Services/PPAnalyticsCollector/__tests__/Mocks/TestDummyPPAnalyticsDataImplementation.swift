////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class TestDummyPPAnalyticsDataImplementation: PPAnalyticsData {
	
	var lastSubmissionAnalytics: Date?
	var lastAppReset: Date?
	var lastSubmittedPPAData: String?
	var currentENFRiskExposureMetadata: RiskExposureMetadata?
	var previousENFRiskExposureMetadata: RiskExposureMetadata?
	var currentCheckinRiskExposureMetadata: RiskExposureMetadata?
	var previousCheckinRiskExposureMetadata: RiskExposureMetadata?
	var userMetadata: UserMetadata?
	var clientMetadata: ClientMetadata?
	var pcrKeySubmissionMetadata: KeySubmissionMetadata?
	var antigenKeySubmissionMetadata: KeySubmissionMetadata?
	var pcrTestResultMetadata: TestResultMetadata?
	var antigenTestResultMetadata: TestResultMetadata?
	var exposureWindowsMetadata: ExposureWindowsMetadata?
	var currentExposureWindows: [SubmissionExposureWindow]?
	var dateOfConversionToENFHighRisk: Date?
	var dateOfConversionToCheckinHighRisk: Date?
}
