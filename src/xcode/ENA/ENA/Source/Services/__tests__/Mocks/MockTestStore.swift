//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

#if DEBUG

final class MockTestStore: Store, PPAnalyticsData {
	var firstPlaybookExecution: Date?
	var lastBackgroundFakeRequest: Date = .init()
	var hasSeenBackgroundFetchAlert: Bool = false
	var enfRiskCalculationResult: ENFRiskCalculationResult?
	var checkinRiskCalculationResult: CheckinRiskCalculationResult?
	var shouldShowRiskStatusLoweredAlert: Bool = false
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

	func wipeAll(key: String?) {}
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
	
	// MARK: - LocalStatisticsCaching

	var localStatistics: [LocalStatisticsMetadata] = []
	var selectedLocalStatisticsDistricts: [LocalStatisticsDistrict] = []

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
	var dateOfConversionToENFHighRisk: Date?
	var dateOfConversionToCheckinHighRisk: Date?

	// MARK: - ErrorLogProviding

	var ppacApiTokenEls: TimestampedToken?
	var otpTokenEls: OTPToken?
	var otpElsAuthorizationDate: Date?
	#if !RELEASE
	var elsLoggingActiveAtStartup: Bool = true
	#endif

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

	// MARK: - AntigenTestProfileStoring

	lazy var antigenTestProfileSubject = {
		CurrentValueSubject<AntigenTestProfile?, Never>(antigenTestProfile)
	}()
	var antigenTestProfile: AntigenTestProfile? {
		didSet {
			antigenTestProfileSubject.value = antigenTestProfile
		}
	}
	var antigenTestProfileInfoScreenShown: Bool = false

	// MARK: - HealthCertificateStoring

	var healthCertificateInfoScreenShown: Bool = false
	var healthCertifiedPersons: [HealthCertifiedPerson] = []
	var testCertificateRequests: [TestCertificateRequest] = []
	var unseenTestCertificateCount: Int = 0

	// MARK: - Protocol VaccinationCaching

	var vaccinationCertificateValueDataSets: VaccinationValueDataSets?

	// MARK: - Protocol HealthCertificateValidationCaching

	var validationOnboardedCountriesCache: HealthCertificateValidationOnboardedCountriesCache?
	var acceptanceRulesCache: ValidationRulesCache?
	var invalidationRulesCache: ValidationRulesCache?

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
}

#endif
