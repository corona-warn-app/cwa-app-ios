//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class MockTestStore: Store, AppConfigCaching, PrivacyPreservingProviding {

	var warnOthersNotificationOneTimer: TimeInterval = WarnOthersNotificationsTimeInterval.intervalOne
	var warnOthersNotificationTwoTimer: TimeInterval = WarnOthersNotificationsTimeInterval.intervalTwo

	var positiveTestResultWasShown: Bool = false
	var isAllowedToPerformBackgroundFakeRequests = false
	var firstPlaybookExecution: Date?
	var lastBackgroundFakeRequest: Date = .init()
	var hasSeenBackgroundFetchAlert: Bool = false
	var riskCalculationResult: RiskCalculationResult?
	var shouldShowRiskStatusLoweredAlert: Bool = false
	var tracingStatusHistory: TracingStatusHistory = []
	var testResultReceivedTimeStamp: Int64?
	func clearAll(key: String?) {}
	var hasSeenSubmissionExposureTutorial: Bool = false
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?
	var numberOfSuccesfulSubmissions: Int64?
	var initialSubmitCompleted: Bool = false
	var exposureActivationConsentAcceptTimestamp: Int64?
	var exposureActivationConsentAccept: Bool = false
	var isOnboarded: Bool = false
	var onboardingVersion: String = ""
	var finishedDeltaOnboardings: [String: [String]] = [String: [String]]()
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
	var registrationToken: String?
	var allowRiskChangesNotification: Bool = true
	var allowTestsStatusNotification: Bool = true
	var userNeedsToBeInformedAboutHowRiskDetectionWorks = false
	var selectedServerEnvironment: ServerEnvironmentData = ServerEnvironment().defaultEnvironment()
	var wasRecentDayKeyDownloadSuccessful = false
	var wasRecentHourKeyDownloadSuccessful = false
	var lastKeyPackageDownloadDate: Date = .distantPast
	var deviceTimeLastStateChange: Date = Date()
	var deviceTimeCheckResult: DeviceTimeCheck.TimeCheckResult = .correct
	var wasDeviceTimeErrorShown = false
	var isSubmissionConsentGiven = false
	var submissionKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]?
	var submissionCountries: [Country] = [.defaultCountry()]
	var submissionSymptomsOnset: SymptomsOnset = .noInformation
	var journalWithExposureHistoryInfoScreenShown: Bool = false
	var dateOfConversionToHighRisk: Date?
	
	#if !RELEASE
	// Settings from the debug menu.
	var fakeSQLiteError: Int32?
	var mostRecentRiskCalculation: RiskCalculation?
	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration?
	var dmKillDeviceTimeCheck = false
	var forceAPITokenAuthorization = false
	#endif

	// MARK: - AppConfigCaching

	var appConfigMetadata: AppConfigMetadata?

	// MARK: - StatisticsCaching

	var statistics: StatisticsMetadata?

	// MARK: - PrivacyPreservingProviding

	var isPrivacyPreservingAnalyticsConsentGiven: Bool = false
	var otpToken: OTPToken?
	var otpAuthorizationDate: Date?
	var ppacApiToken: TimestampedToken?
	var lastSubmissionAnalytics: Date?
	var lastAppReset: Date?
	var lastSubmittedPPAData: String?
	var currentRiskExposureMetadata: RiskExposureMetadata?
	var previousRiskExposureMetadata: RiskExposureMetadata?
	var userMetadata: UserMetadata?
	var clientMetadata: ClientMetadata?
	var testResultMetadata: TestResultMetaData?
}
