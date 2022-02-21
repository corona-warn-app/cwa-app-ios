//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification
import OpenCombine

protocol StoreProtocol: AnyObject {

	var isOnboarded: Bool { get set }
	var onboardingVersion: String { get set }
	var finishedDeltaOnboardings: [String: [String]] { get set }
	var dateOfAcceptedPrivacyNotice: Date? { get set }
	var developerSubmissionBaseURLOverride: String? { get set }
	var developerDistributionBaseURLOverride: String? { get set }
	var developerVerificationBaseURLOverride: String? { get set }

	var appInstallationDate: Date? { get set }

	/// A boolean flag that indicates whether the user has seen the background fetch disabled alert.
	var hasSeenBackgroundFetchAlert: Bool { get set }

	/// An integer value representing the timestamp when the user
	/// accepted to submit his diagnosisKeys with the CWA submission service.
	var exposureActivationConsentAcceptTimestamp: Int64? { get set }

	/// A boolean storing if the user has confirmed to submit
	/// his diagnosiskeys to the CWA submission service.
	var exposureActivationConsentAccept: Bool { get set }

	var referenceDateForRateLimitLogger: Date? { get set }

	var enfRiskCalculationResult: ENFRiskCalculationResult? { get set }

	var checkinRiskCalculationResult: CheckinRiskCalculationResult? { get set }

	/// Set to true whenever a risk calculation changes the risk from .high to .low
	var shouldShowRiskStatusLoweredAlert: Bool { get set }

	/// `true` if the user needs to be informed about how risk detection works.
	/// We only inform the user once. By default the value of this property is `true`.
	var userNeedsToBeInformedAboutHowRiskDetectionWorks: Bool { get set }

	/// `true` if the user needs to be shown the QR code scanner tooltip.
	/// We only show it once. By default the value of this property is `true`.
	var shouldShowQRScannerTooltip: Bool { get set }

	/// Time when the app sent the last background fake request.
	var lastBackgroundFakeRequest: Date { get set }

	/// The time when the playbook was executed in background.
	var firstPlaybookExecution: Date? { get set }

	var wasRecentDayKeyDownloadSuccessful: Bool { get set }

	var wasRecentHourKeyDownloadSuccessful: Bool { get set }

	var lastKeyPackageDownloadDate: Date { get set }

	var submissionKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]? { get set }
	
	var submissionCheckins: [Checkin] { get set }

	var submissionCountries: [Country] { get set }

	var submissionSymptomsOnset: SymptomsOnset { get set }

	var journalWithExposureHistoryInfoScreenShown: Bool { get set }

	func wipeAll(key: String?)

	#if !RELEASE
	/// Settings from the debug menu.
	var fakeSQLiteError: Int32? { get set }

	var mostRecentRiskCalculation: ENFRiskCalculation? { get set }

	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration? { get set }

	var forceAPITokenAuthorization: Bool { get set }
	
	var recentTraceLocationCheckedInto: DMRecentTraceLocationCheckedInto? { get set }

	#endif

}

protocol DeviceTimeCheckStoring: AnyObject {
	var deviceTimeCheckResult: DeviceTimeCheck.TimeCheckResult { get set }
	var deviceTimeLastStateChange: Date { get set }
	var wasDeviceTimeErrorShown: Bool { get set }
}

protocol AppFeaturesStoring: AnyObject {
	#if !RELEASE
	var dmKillDeviceTimeCheck: Bool { get set }
	var unencryptedCheckinsEnabled: Bool { get set }
	#endif
}

protocol TicketValidationStoring: AnyObject {
	#if !RELEASE
	var skipAllowlistValidation: Bool { get set }
	#endif
}

protocol AppConfigCaching: AnyObject {
	var appConfigMetadata: AppConfigMetadata? { get set }
}

protocol StatisticsCaching: AnyObject {
	var statistics: StatisticsMetadata? { get set }
}

protocol LocalStatisticsCaching: AnyObject {
	var localStatistics: [LocalStatisticsMetadata] { get set }
	var selectedLocalStatisticsRegions: [LocalStatisticsRegion] { get set }
}

protocol PrivacyPreservingProviding: AnyObject {
	/// A boolean storing if the user has already confirmed to collect and submit the data for PPA. By setting it, the existing anlytics data will be reset.
	var isPrivacyPreservingAnalyticsConsentGiven: Bool { get set }
	// Do not mix up this property with the real UserMetadata in the PPAnalyticsData protocol
	var userData: UserMetadata? { get set }
	/// OTP for user survey link generation (Edus)
	var otpTokenEdus: OTPToken? { get set }
	/// Date of last otp authorization
	var otpEdusAuthorizationDate: Date? { get set }
	/// PPAC Edus token
	var ppacApiTokenEdus: TimestampedToken? { get set }
}

protocol ErrorLogProviding: AnyObject {
	/// PPAC token for error log support (Els)
	var ppacApiTokenEls: TimestampedToken? { get set }
	/// OTP for error log support (Els)
	var otpTokenEls: OTPToken? { get set }
	/// Date of last otp authorization
	var otpElsAuthorizationDate: Date? { get set }
	/// Last logged app version number
	var lastLoggedAppVersionNumber: Version? { get set }
	/// Timestamp of last logged app version number
	var lastLoggedAppVersionTimestamp: Date? { get set }
	
	#if !RELEASE
	/// For DeveloperMenu - Indicates if the ELS shall be activated or not at startup
	var elsLoggingActiveAtStartup: Bool { get set }
	#endif
}

protocol ErrorLogUploadHistoryProviding: AnyObject {
	/// Collection of previous upload 'receipts'
	var elsUploadHistory: [ErrorLogUploadReceipt] { get set }
}

protocol EventRegistrationCaching: AnyObject {
	/// Event registration - Flag that indicates if the recent trace warning download was successful or not.
	var wasRecentTraceWarningDownloadSuccessful: Bool { get set }
	
	var checkinInfoScreenShown: Bool { get set }

	var traceLocationsInfoScreenShown: Bool { get set }

	var shouldAddCheckinToContactDiaryByDefault: Bool { get set }
	
	var qrCodePosterTemplateMetadata: QRCodePosterTemplateMetadata? { get set }
}

protocol VaccinationCaching: AnyObject {
	var vaccinationCertificateValueDataSets: VaccinationValueDataSets? { get set }
}

protocol WarnOthersTimeIntervalStoring {

	/// Delay time in seconds, when the first notification to warn others will be shown,
	var warnOthersNotificationOneTimeInterval: TimeInterval { get set }

	/// Delay time in seconds, when the first notification to warn others will be shown,
	var warnOthersNotificationTwoTimeInterval: TimeInterval { get set }

}

protocol CoronaTestStoring {

	var pcrTest: PCRTest? { get set }

	var antigenTest: AntigenTest? { get set }
}

protocol AntigenTestProfileStoring: AnyObject {

	var antigenTestProfileSubject: CurrentValueSubject<AntigenTestProfile?, Never> { get }

	var antigenTestProfile: AntigenTestProfile? { get set }

	var antigenTestProfileInfoScreenShown: Bool { get set }

}

protocol HealthCertificateStoring: AnyObject {

	var healthCertificateInfoScreenShown: Bool { get set }

	var healthCertifiedPersons: [HealthCertifiedPerson] { get set }

	var testCertificateRequests: [TestCertificateRequest] { get set }

	var lastSelectedValidationCountry: Country { get set }

	var lastSelectedValidationDate: Date { get set }
	
	var lastBoosterNotificationsExecutionDate: Date? { get set }

	var healthCertifiedPersonsVersion: Int? { get set }
	
	var lastSelectedScenarioIdentifier: String? { get set }

	var dccAdmissionCheckScenarios: DCCAdmissionCheckScenarios? { get set }

}

/// this section contains only deprecated stuff, please do not add new things here
protocol CoronaTestStoringLegacy {

	var registrationToken: String? { get set }

	var teleTan: String? { get set }

	/// A secret allowing the client to upload the diagnosisKey set.
	var tan: String? { get set }

	var testGUID: String? { get set }

	var devicePairingConsentAccept: Bool { get set }

	var devicePairingConsentAcceptTimestamp: Int64? { get set }

	var devicePairingSuccessfulTimestamp: Int64? { get set }

	/// Timestamp that represents the date at which
	/// the user has received a test result.
	var testResultReceivedTimeStamp: Int64? { get set }

	/// Date when the test was registered for both TAN and QR
	var testRegistrationDate: Date? { get set }

	/// Timestamp representing the last successful diagnosis keys submission.
	/// This is needed to allow in the future delta submissions of diagnosis keys since the last submission.
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64? { get set }

	var positiveTestResultWasShown: Bool { get set }

	var isSubmissionConsentGiven: Bool { get set }

}

protocol DSCListCaching: AnyObject {
	// the cache for last fetched DSC List
	var dscList: DSCListMetaData? { get set }
}

protocol RecycleBinStoring: AnyObject {
	var recycleBinItemsSubject: CurrentValueSubject<Set<RecycleBinItem>, Never> { get }

	var recycleBinItems: Set<RecycleBinItem> { get set }
}

protocol HomeBadgeStoring: AnyObject {
	var badgesData: [HomeBadgeWrapper.BadgeType: Int?] { get set }
}

protocol KeyValueCacheStoring: AnyObject {
	var keyValueCacheVersion: Int { get set }
}

// swiftlint:disable all
/// Wrapper protocol
protocol Store:
    AntigenTestProfileStoring,
	AppConfigCaching,
	CoronaTestStoring,
	CoronaTestStoringLegacy,
	ErrorLogProviding,
	ErrorLogUploadHistoryProviding,
	EventRegistrationCaching,
	HealthCertificateStoring,
	PrivacyPreservingProviding,
	StatisticsCaching,
	LocalStatisticsCaching,
	StoreProtocol,
	VaccinationCaching,
	WarnOthersTimeIntervalStoring,
	DSCListCaching,
	DeviceTimeCheckStoring,
	AppFeaturesStoring,
	RecycleBinStoring,
	TicketValidationStoring,
	HomeBadgeStoring,
	KeyValueCacheStoring
{}
// swiftlint:enable all
