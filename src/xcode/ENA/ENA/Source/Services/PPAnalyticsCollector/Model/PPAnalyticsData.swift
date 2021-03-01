////
// 🦠 Corona-Warn-App
//

import Foundation

/// We put this protocol and its implementation in a seperate file because this protocol is only used by the collector. And only the collector should use it!
/// So if we do this, we can hide the analytics relevant properties in the secure store from accessing of the Store protocol.
/// ⚠️ If you add some new data here, you MUST NOT forget to nil this data in the deleteAnalyticsData() method of the Analytics. ⚠️

protocol PPAnalyticsData: AnyObject {
	/// Last succesfull submission of analytics data. Needed for analytics submission.
	var lastSubmissionAnalytics: Date? { get set }
	/// Date of last app reset. Needed for analytics submission.
	var lastAppReset: Date? { get set }
	/// Content of last submitted data. Needed for analytics submission dev menu.
	var lastSubmittedPPAData: String? { get set }
	/// Analytics data.
	var currentRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data.
	var previousRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data.
	var userMetadata: UserMetadata? { get set }
	/// Analytics data.
	var clientMetadata: ClientMetadata? { get set }
	/// Analytics data
	var keySubmissionMetadata: KeySubmissionMetadata? { get set }
	/// Analytics data.
	var testResultMetadata: TestResultMetadata? { get set }
	/// Analytics data.
	var exposureWindowsMetadata: ExposureWindowsMetadata? { get set }
}

extension SecureStore: PPAnalyticsData {
		
	var lastSubmissionAnalytics: Date? {
		get { kvStore["lastSubmissionAnalytics"] as Date? }
		set { kvStore["lastSubmissionAnalytics"] = newValue }
	}

	var lastAppReset: Date? {
		get { kvStore["lastAppReset"] as Date? }
		set { kvStore["lastAppReset"] = newValue }
	}

	var lastSubmittedPPAData: String? {
		get { kvStore["lastSubmittedPPAData"] as String? }
		set { kvStore["lastSubmittedPPAData"] = newValue }
	}

	var currentRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["currentRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["currentRiskExposureMetadata"] = newValue }
	}

	var previousRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["previousRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["previousRiskExposureMetadata"] = newValue }
	}

	var userMetadata: UserMetadata? {
		get { kvStore["userMetadata"] as UserMetadata? ?? nil }
		set { kvStore["userMetadata"] = newValue }
	}

	var testResultMetadata: TestResultMetadata? {
		get { kvStore["testResultaMetadata"] as TestResultMetadata? ?? nil }
		set { kvStore["testResultaMetadata"] = newValue }
	}

	var clientMetadata: ClientMetadata? {
		get { kvStore["clientMetadata"] as ClientMetadata? ?? nil }
		set { kvStore["clientMetadata"] = newValue }
	}

	var keySubmissionMetadata: KeySubmissionMetadata? {
		get { kvStore["keySubmissionMetadata"] as KeySubmissionMetadata? ?? nil }
		set { kvStore["keySubmissionMetadata"] = newValue }
	}

	var exposureWindowsMetadata: ExposureWindowsMetadata? {
		get { kvStore["exposureWindowsMetadata"] as ExposureWindowsMetadata? ?? nil }
		set { kvStore["exposureWindowsMetadata"] = newValue }
	}
}
