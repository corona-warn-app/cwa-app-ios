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
	var currentENFRiskExposureMetadata: RiskExposureMetadata?
	var previousENFRiskExposureMetadata: RiskExposureMetadata?
	var currentCheckinRiskExposureMetadata: RiskExposureMetadata?
	var previousCheckinRiskExposureMetadata: RiskExposureMetadata?
	var userMetadata: UserMetadata?
	var clientMetadata: ClientMetadata?
	var keySubmissionMetadata: KeySubmissionMetadata?
	var testResultMetadata: TestResultMetadata?
	var exposureWindowsMetadata: ExposureWindowsMetadata?
	var dateOfConversionToENFHighRisk: Date?
	var dateOfConversionToCheckinHighRisk: Date?
}
