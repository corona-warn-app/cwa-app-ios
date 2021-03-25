//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

protocol StoreProtocol: AnyObject {

	var isOnboarded: Bool { get set }
	var onboardingVersion: String { get set }
	var finishedDeltaOnboardings: [String: [String]] { get set }
	var dateOfAcceptedPrivacyNotice: Date? { get set }
	var developerSubmissionBaseURLOverride: String? { get set }
	var developerDistributionBaseURLOverride: String? { get set }
	var developerVerificationBaseURLOverride: String? { get set }
	var teleTan: String? { get set }

	/// A secret allowing the client to upload the diagnosisKey set.
	var tan: String? { get set }
	var testGUID: String? { get set }
	var devicePairingConsentAccept: Bool { get set }
	var devicePairingConsentAcceptTimestamp: Int64? { get set }
	var devicePairingSuccessfulTimestamp: Int64? { get set }

	var allowRiskChangesNotification: Bool { get set }
	var allowTestsStatusNotification: Bool { get set }

	var appInstallationDate: Date? { get set }

	var registrationToken: String? { get set }
	var hasSeenSubmissionExposureTutorial: Bool { get set }

	/// A boolean flag that indicates whether the user has seen the background fetch disabled alert.
	var hasSeenBackgroundFetchAlert: Bool { get set }

	/// Timestamp that represents the date at which
	/// the user has received a test reult.
	var testResultReceivedTimeStamp: Int64? { get set }

	/// Date when the test was registered for both TAN and QR
	var testRegistrationDate: Date? { get set }

	/// Timestamp representing the last successful diagnosis keys submission.
	/// This is needed to allow in the future delta submissions of diagnosis keys since the last submission.
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64? { get set }

	/// The number of successful submissions to the CWA-submission backend service.
	var numberOfSuccesfulSubmissions: Int64? { get set }

	/// Boolean representing the initial submit completed state.
	var initialSubmitCompleted: Bool { get set }

	/// An integer value representing the timestamp when the user
	/// accepted to submit his diagnosisKeys with the CWA submission service.
	var exposureActivationConsentAcceptTimestamp: Int64? { get set }

	/// A boolean storing if the user has confirmed to submit
	/// his diagnosiskeys to the CWA submission service.
	var exposureActivationConsentAccept: Bool { get set }

	var riskCalculationResult: RiskCalculationResult? { get set }

	var checkinRiskCalculationResult: CheckinRiskCalculationResult? { get set }

	/// Date when the risk was changed to high
	var dateOfConversionToHighRisk: Date? { get set }

	/// Set to true whenever a risk calculation changes the risk from .high to .low
	var shouldShowRiskStatusLoweredAlert: Bool { get set }

	/// `true` if the user needs to be informed about how risk detection works.
	/// We only inform the user once. By default the value of this property is `true`.
	var userNeedsToBeInformedAboutHowRiskDetectionWorks: Bool { get set }

	/// True if the app is allowed to execute fake requests (for plausible deniability) in the background.
	var isAllowedToPerformBackgroundFakeRequests: Bool { get set }

	/// Time when the app sent the last background fake request.
	var lastBackgroundFakeRequest: Date { get set }

	/// The time when the playbook was executed in background.
	var firstPlaybookExecution: Date? { get set }

	/// Delay time in seconds, when the first notification to warn others will be shown,
	var warnOthersNotificationOneTimer: TimeInterval { get set }

	/// Delay time in seconds, when the first notification to warn others will be shown,
	var warnOthersNotificationTwoTimer: TimeInterval { get set }

	var wasRecentDayKeyDownloadSuccessful: Bool { get set }

	var wasRecentHourKeyDownloadSuccessful: Bool { get set }

	var lastKeyPackageDownloadDate: Date { get set }

	var deviceTimeCheckResult: DeviceTimeCheck.TimeCheckResult { get set }

	var deviceTimeLastStateChange: Date { get set }

	var wasDeviceTimeErrorShown: Bool { get set }

	var positiveTestResultWasShown: Bool { get set }

	var isSubmissionConsentGiven: Bool { get set }

	var submissionKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]? { get set }

	var submissionCountries: [Country] { get set }

	var submissionSymptomsOnset: SymptomsOnset { get set }

	var journalWithExposureHistoryInfoScreenShown: Bool { get set }
	
	var checkinInfoScreenShown: Bool { get set }

	var traceLocationsInfoScreenShown: Bool { get set }

	func clearAll(key: String?)

	#if !RELEASE
	/// Settings from the debug menu.
	var fakeSQLiteError: Int32? { get set }

	var mostRecentRiskCalculation: RiskCalculation? { get set }

	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration? { get set }

	var dmKillDeviceTimeCheck: Bool { get set }

	var forceAPITokenAuthorization: Bool { get set }

	#endif

}

protocol ServerEnvironmentProviding {
	var selectedServerEnvironment: ServerEnvironmentData { get set }
}

protocol AppConfigCaching: AnyObject {
	var appConfigMetadata: AppConfigMetadata? { get set }
}

protocol StatisticsCaching: AnyObject {
	var statistics: StatisticsMetadata? { get set }
}

protocol PrivacyPreservingProviding: AnyObject {
	/// A boolean storing if the user has already confirmed to collect and submit the data for PPA. By setting it, the existing anlytics data will be reset.
	var isPrivacyPreservingAnalyticsConsentGiven: Bool { get set }
	// Do not mix up this property with the real UserMetadata in the PPAnalyticsData protocol
	var userData: UserMetadata? { get set }
	/// OTP for user survey link generation
	var otpToken: OTPToken? { get set }
	/// Date of last otp authorization
	var otpAuthorizationDate: Date? { get set }
	/// PPAC Token storage
	var ppacApiToken: TimestampedToken? { get set }
}

/// Wrapper protocol
protocol Store: StoreProtocol, AppConfigCaching, StatisticsCaching, ServerEnvironmentProviding, PrivacyPreservingProviding {}
