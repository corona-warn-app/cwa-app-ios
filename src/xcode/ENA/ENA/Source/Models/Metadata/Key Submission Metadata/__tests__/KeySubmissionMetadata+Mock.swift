//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension KeySubmissionMetadata {

	static func mock(
		submitted: Bool = false,
		submittedInBackground: Bool = false,
		submittedAfterCancel: Bool = false,
		submittedAfterSymptomFlow: Bool = false,
		lastSubmissionFlowScreen: LastSubmissionFlowScreen = .submissionFlowScreenUnknown,
		advancedConsentGiven: Bool = false,
		hoursSinceTestResult: Int32 = 0,
		hoursSinceTestRegistration: Int32 = 0,
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int32 = 0,
		hoursSinceHighRiskWarningAtTestRegistration: Int32 = 0,
		submittedWithTeleTAN: Bool = false,
		submittedAfterRapidAntigenTest: Bool = false,
		daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: Int32 = 0,
		hoursSinceCheckinHighRiskWarningAtTestRegistration: Int32 = 0,
		submittedWithCheckIns: Bool? = nil
	) -> KeySubmissionMetadata {
		KeySubmissionMetadata(
			submitted: submitted,
			submittedInBackground: submittedInBackground,
			submittedAfterCancel: submittedAfterCancel,
			submittedAfterSymptomFlow: submittedAfterSymptomFlow,
			lastSubmissionFlowScreen: lastSubmissionFlowScreen,
			advancedConsentGiven: advancedConsentGiven,
			hoursSinceTestResult: hoursSinceTestResult,
			hoursSinceTestRegistration: hoursSinceTestRegistration,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			hoursSinceHighRiskWarningAtTestRegistration: hoursSinceHighRiskWarningAtTestRegistration,
			submittedWithTeleTAN: submittedWithTeleTAN,
			submittedAfterRapidAntigenTest: submittedAfterRapidAntigenTest,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: hoursSinceCheckinHighRiskWarningAtTestRegistration,
			submittedWithCheckIns: submittedWithCheckIns
		)
	}

}
