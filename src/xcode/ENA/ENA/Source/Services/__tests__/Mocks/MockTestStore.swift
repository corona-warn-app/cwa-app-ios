//
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG

final class MockTestStore: Store, PPAnalyticsData {

	var firstPlaybookExecution: Date?
	var lastBackgroundFakeRequest: Date = .init()
	var hasSeenBackgroundFetchAlert: Bool = false
	var enfRiskCalculationResult: ENFRiskCalculationResult?
	var checkinRiskCalculationResult: CheckinRiskCalculationResult?
	var shouldShowRiskStatusLoweredAlert: Bool = false
	func clearAll(key: String?) {}
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
	var allowRiskChangesNotification: Bool = true
	var allowTestsStatusNotification: Bool = true
	var appInstallationDate: Date? = Date()
	var userNeedsToBeInformedAboutHowRiskDetectionWorks = false
	var selectedServerEnvironment: EnvironmentData = Environments().defaultEnvironment()
	var wasRecentDayKeyDownloadSuccessful = false
	var wasRecentHourKeyDownloadSuccessful = false
	var lastKeyPackageDownloadDate: Date = .distantPast
	var deviceTimeLastStateChange: Date = Date()
	var deviceTimeCheckResult: DeviceTimeCheck.TimeCheckResult = .correct
	var wasDeviceTimeErrorShown = false
	var submissionKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]?
	var submissionCheckins: [Checkin] = []
	var submissionCountries: [Country] = [.defaultCountry()]
	var submissionSymptomsOnset: SymptomsOnset = .noInformation
	var journalWithExposureHistoryInfoScreenShown: Bool = false
	var dateOfConversionToHighRisk: Date?

	#if !RELEASE
	// Settings from the debug menu.
	var fakeSQLiteError: Int32?
	var mostRecentRiskCalculation: ENFRiskCalculation?
	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration?
	var dmKillDeviceTimeCheck = false
	var forceAPITokenAuthorization = false
	var recentTraceLocationCheckedInto: DMRecentTraceLocationCheckedInto?
	#endif

	// MARK: - AppConfigCaching

	var appConfigMetadata: AppConfigMetadata?

	// MARK: - StatisticsCaching

	var statistics: StatisticsMetadata?

	// MARK: - PrivacyPreservingProviding

	var isPrivacyPreservingAnalyticsConsentGiven: Bool = false
	var otpTokenEdus: OTPToken?
	var otpEdusAuthorizationDate: Date?
	var ppacApiTokenEdus: TimestampedToken?
	var userData: UserMetadata?

	// MARK: - PPAnalyticsData

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

	// MARK: - ErrorLogProviding
	
	var ppacApiTokenEls: TimestampedToken?
	var otpTokenEls: OTPToken?
	var otpElsAuthorizationDate: Date?

	// MARK: - ErrorLogHistory

	var elsUploadHistory: [ErrorLogUploadReceipt] = []
	
	// MARK: - EventRegistrationCaching
	
	var wasRecentTraceWarningDownloadSuccessful: Bool = false
	var checkinInfoScreenShown: Bool = false
	var traceLocationsInfoScreenShown: Bool = false
	var shouldAddCheckinToContactDiaryByDefault = true
	var qrCodePosterTemplateMetadata: QRCodePosterTemplateMetadata?

	// MARK: - WarnOthersTimeIntervalStoring

	var warnOthersNotificationOneTimeInterval: TimeInterval = WarnOthersNotificationsTimeInterval.intervalOne
	var warnOthersNotificationTwoTimeInterval: TimeInterval = WarnOthersNotificationsTimeInterval.intervalTwo

	// MARK: - CoronaTestStoring

	var pcrTest: PCRTest?
	var antigenTest: AntigenTest?

	// MARK: - CoronaTestStoringLegacy

	var registrationToken: String?
	var teleTan: String?
	var tan: String?
	var testGUID: String?
	var devicePairingConsentAccept: Bool = false
	var devicePairingConsentAcceptTimestamp: Int64?
	var devicePairingSuccessfulTimestamp: Int64?
	var testResultReceivedTimeStamp: Int64?
	var testRegistrationDate: Date?
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?
	var positiveTestResultWasShown: Bool = false
	var isSubmissionConsentGiven = false
	var antigenTestProfile: AntigenTestProfile?
}

#endif
