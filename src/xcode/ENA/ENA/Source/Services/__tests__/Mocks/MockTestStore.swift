//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

#if !RELEASE

final class MockTestStore: Store, PPAnalyticsData {
	init() {
#if DEBUG
		if isUITesting {
			self.showAnotherHighExposureAlert = LaunchArguments.risk.anotherHighEncounter.boolValue
			self.userNeedsToBeInformedAboutHowRiskDetectionWorks = LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks.boolValue
		}
#endif
	}

	var firstPlaybookExecution: Date?
	var lastBackgroundFakeRequest: Date = .init()
	var hasSeenBackgroundFetchAlert: Bool = false
	var referenceDateForRateLimitLogger: Date?
	var enfRiskCalculationResult: ENFRiskCalculationResult?
	var checkinRiskCalculationResult: CheckinRiskCalculationResult?
	var showAnotherHighExposureAlert: Bool = false
	var shouldShowRiskStatusLoweredAlert: Bool = false
	var exposureActivationConsentAcceptTimestamp: Int64?
	var exposureActivationConsentAccept: Bool = false
	var isOnboarded: Bool = false
	var cclVersion: String?
	var onboardingVersion: String = ""
	var finishedDeltaOnboardings: [String: [String]] = [String: [String]]()
	var dateOfAcceptedPrivacyNotice: Date?
	var allowsCellularUse: Bool = false
	var developerSubmissionBaseURLOverride: String?
	var developerDistributionBaseURLOverride: String?
	var developerVerificationBaseURLOverride: String?
	var appInstallationDate: Date? = Date()
	var userNeedsToBeInformedAboutHowRiskDetectionWorks = false
	var shouldShowQRScannerTooltip = false
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
	var lastBoosterNotificationsExecutionDate: Date?
	var mostRecentKeySubmissionDate: Date?
	var firstReliableTimeStamp: Date?
	func wipeAll(key: String?) {}
	#if !RELEASE
	// Settings from the debug menu.
	var fakeSQLiteError: Int32?
	var mostRecentRiskCalculation: ENFRiskCalculation?
	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration?
	var forceAPITokenAuthorization = false
	var recentTraceLocationCheckedInto: DMRecentTraceLocationCheckedInto?
	var isSrsPrechecksEnabled = false
	var hibernationStartDate: Date?
	#endif

	// MARK: - AppConfigCaching

	var appConfigMetadata: AppConfigMetadata?

	// MARK: - StatisticsCaching

	var statistics: StatisticsMetadata?
	
	// MARK: - LocalStatisticsCaching

	let localStatisticsMetadataQueue = DispatchQueue(label: "com.sap.mockstore.LocalStatisticsMetadata")

	var _localStatistics = [LocalStatisticsMetadata]()
	var localStatistics: [LocalStatisticsMetadata] {
		get { localStatisticsMetadataQueue.sync { _localStatistics } }
		set { localStatisticsMetadataQueue.sync { _localStatistics = newValue } }
	}
	
	var selectedLocalStatisticsRegions: [LocalStatisticsRegion] = []

	// MARK: - SRS Providing

	var ppacApiTokenSrs: TimestampedToken?
	var previousPpacApiTokenSrs: TimestampedToken?
	var otpTokenSrs: OTPToken?
    var otpSrsAuthorizationDate: Date?
	/// DEPRECATED, Only used for dev menu testing for API tokens
	var ppacApiTokenEdus: TimestampedToken?
	/// DEPRECATED, Only used for dev menu testing for API tokens
	var ppacApiTokenEls: TimestampedToken?

	// MARK: - PrivacyPreservingProviding

	var isPrivacyPreservingAnalyticsConsentGiven: Bool = false
	var otpTokenEdus: OTPToken?
	var otpEdusAuthorizationDate: Date?
	var apiTokenPPAC: TimestampedToken?
	var previousAPITokenPPAC: TimestampedToken?
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
	var srsKeySubmissionMetadata: KeySubmissionMetadata?
	var pcrTestResultMetadata: TestResultMetadata?
	var antigenTestResultMetadata: TestResultMetadata?
	var exposureWindowsMetadata: ExposureWindowsMetadata?
	var currentExposureWindows: [SubmissionExposureWindow]? = []
	var dateOfConversionToENFHighRisk: Date?
	var dateOfConversionToCheckinHighRisk: Date?

	// MARK: - ErrorLogProviding

	var lastLoggedAppVersionNumber: Version?
	var lastLoggedAppVersionTimestamp: Date?
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

	var pcrTest: UserPCRTest?
	var antigenTest: UserAntigenTest?
	var familyMemberTests: [FamilyMemberCoronaTest] = []

	// MARK: - AntigenTestProfileStoring

	lazy var antigenTestProfilesSubject = {
		CurrentValueSubject<[AntigenTestProfile], Never>(antigenTestProfiles)
	}()
	var antigenTestProfiles: [AntigenTestProfile] = [] {
		didSet {
			antigenTestProfilesSubject.value = antigenTestProfiles
		}
	}
	var antigenTestProfileInfoScreenShown: Bool = false

	// MARK: - HealthCertificateStoring

	var healthCertificateInfoScreenShown: Bool = false
	var healthCertifiedPersons: [HealthCertifiedPerson] = []
	// assign current version so that existing tests skip migration
	var healthCertifiedPersonsVersion: Int? = kCurrentHealthCertifiedPersonsVersion
	var testCertificateRequests: [TestCertificateRequest] = []
	var lastSelectedValidationCountry: Country = .defaultCountry()
	var lastSelectedValidationDate: Date = Date()
	var lastSelectedScenarioIdentifier: String?
	var dccAdmissionCheckScenarios: DCCAdmissionCheckScenarios?
	var shouldShowRegroupingAlert: Bool = false
	var expiringSoonAndExpiredNotificationsRemoved: Bool = false
	var appVersion: String?
	var shouldShowExportCertificatesTooltip: Bool = true

	// MARK: - RevokedCertificatesStoring

	var revokedCertificates: [String] = []

	// MARK: - Protocol VaccinationCaching

	var vaccinationCertificateValueDataSets: VaccinationValueDataSets?

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

	// MARK: - Protocol DSCListCaching

	var dscList: DSCListMetaData?

	// MARK: - Protocol AppFeaturesStoring
	var dmKillDeviceTimeCheck = false
	var unencryptedCheckinsEnabled = false

	// MARK: - TicketValidationStoring
	var skipAllowlistValidation: Bool = false

	// MARK: - Protocol RecycleBinStoring

	lazy var recycleBinItemsSubject = {
		CurrentValueSubject<Set<RecycleBinItem>, Never>(recycleBinItems)
	}()
	var recycleBinItems: Set<RecycleBinItem> = [] {
		didSet {
			recycleBinItemsSubject.value = recycleBinItems
		}
	}

	// MARK: - HomeBadgeStoring
	var badgesData: [HomeBadgeWrapper.BadgeType: Int?] = [:]

	// MARK: - KeyValueCacheStoring
	var keyValueCacheVersion: Int = 0
}
#endif
