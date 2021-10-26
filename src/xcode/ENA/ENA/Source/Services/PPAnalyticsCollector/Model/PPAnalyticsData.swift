////
// 🦠 Corona-Warn-App
//

import Foundation

/// We put this protocol and its implementation in a separate file because this protocol is only used by the collector. And only the collector should use it!
/// So if we do this, we can hide the analytics relevant properties in the secure store from accessing of the Store protocol.
/// ⚠️ If you add some new data here, you MUST NOT forget to nil this data in the deleteAnalyticsData() method of the Analytics. ⚠️

protocol PPAnalyticsData: AnyObject {
	/// Last successful submission of analytics data. Needed for analytics submission.
	var lastSubmissionAnalytics: Date? { get set }
	/// Date of last app reset. Needed for analytics submission.
	var lastAppReset: Date? { get set }
	/// Content of last submitted data. Needed for analytics submission dev menu.
	var lastSubmittedPPAData: String? { get set }
	/// Analytics data ENF.
	var currentENFRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data ENF.
	var previousENFRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data Checkin.
	var currentCheckinRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data Checkin.
	var previousCheckinRiskExposureMetadata: RiskExposureMetadata? { get set }
	/// Analytics data.
	var userMetadata: UserMetadata? { get set }
	/// Analytics data.
	var clientMetadata: ClientMetadata? { get set }
	/// Analytics data
	var pcrKeySubmissionMetadata: KeySubmissionMetadata? { get set }
	/// Analytics data
	var antigenKeySubmissionMetadata: KeySubmissionMetadata? { get set }
	/// Analytics data.
	var pcrTestResultMetadata: TestResultMetadata? { get set }
	/// Analytics data.
	var antigenTestResultMetadata: TestResultMetadata? { get set }
	/// Analytics data.
	var exposureWindowsMetadata: ExposureWindowsMetadata? { get set }
	/// Stores the exposure windows
	var currentExposureWindows: [SubmissionExposureWindow] { get set }
	/// Date when the ENF risk was changed to high
	var dateOfConversionToENFHighRisk: Date? { get set }
	/// Date when the event risk was changed to high
	var dateOfConversionToCheckinHighRisk: Date? { get set }
	
	
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
	
	var currentENFRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["currentRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["currentRiskExposureMetadata"] = newValue }
	}

	var previousENFRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["previousRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["previousRiskExposureMetadata"] = newValue }
	}
	
	var currentCheckinRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["currentCheckinRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["currentCheckinRiskExposureMetadata"] = newValue }
	}

	var previousCheckinRiskExposureMetadata: RiskExposureMetadata? {
		get { kvStore["previousCheckinRiskExposureMetadata"] as RiskExposureMetadata? ?? nil }
		set { kvStore["previousCheckinRiskExposureMetadata"] = newValue }
	}

	var userMetadata: UserMetadata? {
		get { kvStore["userMetadataAnalytics"] as UserMetadata? }
		set { kvStore["userMetadataAnalytics"] = newValue }
	}

	var pcrTestResultMetadata: TestResultMetadata? {
		get { kvStore["testResultaMetadata"] as TestResultMetadata? }
		set { kvStore["testResultaMetadata"] = newValue }
	}

	var antigenTestResultMetadata: TestResultMetadata? {
		get { kvStore["antigenTestResultMetadata"] as TestResultMetadata? }
		set { kvStore["antigenTestResultMetadata"] = newValue }
	}

	var clientMetadata: ClientMetadata? {
		get { kvStore["clientMetadata"] as ClientMetadata? }
		set { kvStore["clientMetadata"] = newValue }
	}

	var pcrKeySubmissionMetadata: KeySubmissionMetadata? {
		get {
			var metadata = kvStore["keySubmissionMetadata"] as KeySubmissionMetadata? ?? nil

			// Migrate data from old entry 'submittedWithQR'.
			// 'submittedWithQR' was previously used to identify if a PCR test was registered via QR code.
			// Since we now need this information for pcr and antigen tests, this field needs to me migrated to the 'keySubmissionMetadata'.
			// According to the specs for 'Key Submission Metadata' its the other way around, we have a field called 'submittedWithTeleTAN', which identifies if a test was registered via TAN.
			// Since there are only 2 ways (TAN or QR code) to register a test, we can assume 'submittedWithTeleTAN = !submittedWithQR'
			if let _submittedWithQR = kvStore["submittedWithQR"] as? Bool?,
			   let submittedWithQR = _submittedWithQR,
			   metadata?.submittedWithTeleTAN == nil {

				metadata?.submittedWithTeleTAN = !submittedWithQR
				kvStore["submittedWithQR"] = nil
			}

			return metadata
		}
		set { kvStore["keySubmissionMetadata"] = newValue }
	}

	var antigenKeySubmissionMetadata: KeySubmissionMetadata? {
		get { kvStore["antigenKeySubmissionMetadata"] as KeySubmissionMetadata? }
		set { kvStore["antigenKeySubmissionMetadata"] = newValue }
	}

	var exposureWindowsMetadata: ExposureWindowsMetadata? {
		get { kvStore["exposureWindowsMetadata"] as ExposureWindowsMetadata? }
		set { kvStore["exposureWindowsMetadata"] = newValue }
	}
	
	var currentExposureWindows: [SubmissionExposureWindow] {
		get { kvStore["currentExposureWindows"] as [SubmissionExposureWindow]? ?? [] }
		set { kvStore["currentExposureWindows"] = newValue }
	}

	var dateOfConversionToENFHighRisk: Date? {
		// old named key matches not to property name to avoid migration
		get { kvStore["dateOfConversionToHighRisk"] as Date? ?? nil }
		set { kvStore["dateOfConversionToHighRisk"] = newValue }
	}
	
	var dateOfConversionToCheckinHighRisk: Date? {
		get { kvStore["dateOfConversionToCheckinHighRisk"] as Date? ?? nil }
		set { kvStore["dateOfConversionToCheckinHighRisk"] = newValue }
	}
	
	
}
