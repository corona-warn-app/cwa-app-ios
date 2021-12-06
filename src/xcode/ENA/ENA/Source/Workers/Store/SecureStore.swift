//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification
import OpenCombine

// swiftlint:disable file_length

/// The `SecureStore` class implements the `Store` protocol that defines all required storage attributes.
/// It uses an SQLite Database that still needs to be encrypted
final class SecureStore: SecureKeyValueStoring, Store, AntigenTestProfileStoring {

	// MARK: - Init

	init(
		at directoryURL: URL,
		key: String
	) throws {
		self.directoryURL = directoryURL
		self.kvStore = try SQLiteKeyValueStore(with: directoryURL, key: key)
	}

	// MARK: - Protocol Store

	/// Removes most key/value pairs.
	///
	/// Keys whose values are not removed:
	/// * `developerSubmissionBaseURLOverride`
	/// * `developerDistributionBaseURLOverride`
	/// * `developerVerificationBaseURLOverride`
	///
	/// - Note: This is just a wrapper to the `SQLiteKeyValueStore:flush` call
	func flush() {
		do {
			try kvStore.flush()
		} catch {
			Log.error("kv store error", log: .localData, error: error)
		}
	}

	/// Database reset & re-initialization with a given key
	/// - Parameter key: the key for the new database; if no key is given, no new database will be created
	///
	/// - Note: This is just a wrapper to the `SQLiteKeyValueStore:clearAll:` call
	func wipeAll(key: String?) {
		do {
			try kvStore.wipeAll(key: key)
			antigenTestProfileSubject.send(nil)
		} catch {
			Log.error("kv store error", log: .localData, error: error)
		}
	}

	var exposureActivationConsentAcceptTimestamp: Int64? {
		get { kvStore["exposureActivationConsentAcceptTimestamp"] as Int64? ?? 0 }
		set { kvStore["exposureActivationConsentAcceptTimestamp"] = newValue }
	}

	var exposureActivationConsentAccept: Bool {
		get { kvStore["exposureActivationConsentAccept"] as Bool? ?? false }
		set { kvStore["exposureActivationConsentAccept"] = newValue }
	}

	var isOnboarded: Bool {
		get { kvStore["isOnboarded"] as Bool? ?? false }
		set { kvStore["isOnboarded"] = newValue }
	}

	var finishedDeltaOnboardings: [String: [String]] {
		get { kvStore["finishedDeltaOnboardings"] as [String: [String]]? ?? [String: [String]]() }
		set { kvStore["finishedDeltaOnboardings"] = newValue }
	}

	var onboardingVersion: String {
		get { kvStore["onboardingVersion"] as String? ?? "1.4" }
		set { kvStore["onboardingVersion"] = newValue }
	}

	var dateOfAcceptedPrivacyNotice: Date? {
		get { kvStore["dateOfAcceptedPrivacyNotice"] as Date? ?? nil }
		set { kvStore["dateOfAcceptedPrivacyNotice"] = newValue }
	}

	var hasSeenBackgroundFetchAlert: Bool {
		get { kvStore["hasSeenBackgroundFetchAlert"] as Bool? ?? false }
		set { kvStore["hasSeenBackgroundFetchAlert"] = newValue }
	}

	var developerSubmissionBaseURLOverride: String? {
		get { kvStore["developerSubmissionBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerSubmissionBaseURLOverride"] = newValue }
	}

	var developerDistributionBaseURLOverride: String? {
		get { kvStore["developerDistributionBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerDistributionBaseURLOverride"] = newValue }
	}

	var developerVerificationBaseURLOverride: String? {
		get { kvStore["developerVerificationBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerVerificationBaseURLOverride"] = newValue }
	}

	var appInstallationDate: Date? {
		get { kvStore["appInstallationDate"] as Date? }
		set { kvStore["appInstallationDate"] = newValue }
	}

	var referenceDateForRateLimitLogger: Date? {
		get { kvStore["referenceDateForRateLimitLogger"] as Date? }
		set { kvStore["referenceDateForRateLimitLogger"] = newValue }
	}

	var enfRiskCalculationResult: ENFRiskCalculationResult? {
		// Old named key matches not to property name to avoid migration.
		get { kvStore["riskCalculationResult"] as ENFRiskCalculationResult? ?? nil }
		set { kvStore["riskCalculationResult"] = newValue }
	}

	var checkinRiskCalculationResult: CheckinRiskCalculationResult? {
		get { kvStore["checkinRiskCalculationResult"] as CheckinRiskCalculationResult? ?? nil }
		set { kvStore["checkinRiskCalculationResult"] = newValue }
	}

	var shouldShowRiskStatusLoweredAlert: Bool {
		get { kvStore["shouldShowRiskStatusLoweredAlert"] as Bool? ?? false }
		set { kvStore["shouldShowRiskStatusLoweredAlert"] = newValue }
	}

	var userNeedsToBeInformedAboutHowRiskDetectionWorks: Bool {
		get { kvStore["userNeedsToBeInformedAboutHowRiskDetectionWorks"] as Bool? ?? true }
		set { kvStore["userNeedsToBeInformedAboutHowRiskDetectionWorks"] = newValue }
	}

	var shouldShowQRScannerTooltip: Bool {
		get { kvStore["shouldShowQRScannerTooltip"] as Bool? ?? true }
		set { kvStore["shouldShowQRScannerTooltip"] = newValue }
	}

	var lastBackgroundFakeRequest: Date {
		get { kvStore["lastBackgroundFakeRequest"] as Date? ?? Date() }
		set { kvStore["lastBackgroundFakeRequest"] = newValue }
	}

	var firstPlaybookExecution: Date? {
		get { kvStore["firstPlaybookExecution"] as Date? }
		set { kvStore["firstPlaybookExecution"] = newValue }
	}

	var wasRecentDayKeyDownloadSuccessful: Bool {
		get { kvStore["wasRecentDayKeyDownloadSuccessful"] as Bool? ?? false }
		set { kvStore["wasRecentDayKeyDownloadSuccessful"] = newValue }
	}

	var wasRecentHourKeyDownloadSuccessful: Bool {
		get { kvStore["wasRecentHourKeyDownloadSuccessful"] as Bool? ?? false }
		set { kvStore["wasRecentHourKeyDownloadSuccessful"] = newValue }
    }

	var lastKeyPackageDownloadDate: Date {
		get { kvStore["lastKeyPackageDownloadDate"] as Date? ?? .distantPast }
		set { kvStore["lastKeyPackageDownloadDate"] = newValue }
	}

	var submissionKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]? {
		get {
			(kvStore["submissionKeys"] as [Data]?)?.compactMap {
				try? SAP_External_Exposurenotification_TemporaryExposureKey(serializedData: $0)
			}
		}
		set {
			kvStore["submissionKeys"] = newValue?.compactMap { try? $0.serializedData() }
		}
	}
	
	var submissionCheckins: [Checkin] {
		get { kvStore["submissionCheckins"] as [Checkin]? ?? [] }
		set { kvStore["submissionCheckins"] = newValue }
	}

	var submissionCountries: [Country] {
		get {
			let countries = kvStore["submissionCountries"] as [Country]? ?? [.defaultCountry()]
			return countries.map({ Country(withCountryCodeFallback: $0.id) })
		}
		set { kvStore["submissionCountries"] = newValue }
	}

	var submissionSymptomsOnset: SymptomsOnset {
		get { kvStore["submissionSymptomsOnset"] as SymptomsOnset? ?? .noInformation }
		set { kvStore["submissionSymptomsOnset"] = newValue }
	}

	var journalWithExposureHistoryInfoScreenShown: Bool {
		get { kvStore["journalWithExposureHistoryInfoScreenShown"] as Bool? ?? false }
		set { kvStore["journalWithExposureHistoryInfoScreenShown"] = newValue }
	}
	
	var lastBoosterNotificationsExecutionDate: Date? {
		get { kvStore["lastBoosterNotificationsExecutionDate"] as Date? }
		set { kvStore["lastBoosterNotificationsExecutionDate"] = newValue }
	}


    // MARK: - Protocol AntigenTestProfileStoring

	private(set) lazy var antigenTestProfileSubject = CurrentValueSubject<AntigenTestProfile?, Never>(antigenTestProfile)

	var antigenTestProfile: AntigenTestProfile? {
		get { kvStore["antigenTestProfile"] as AntigenTestProfile? }
		set {
			kvStore["antigenTestProfile"] = newValue
			antigenTestProfileSubject.send(newValue)
		}
	}

	var antigenTestProfileInfoScreenShown: Bool {
		get { kvStore["antigenTestProfileInfoScreenShown"] as Bool? ?? false }
		set { kvStore["antigenTestProfileInfoScreenShown"] = newValue }
	}

    // MARK: - Protocol HealthCertificateStoring

	var healthCertificateInfoScreenShown: Bool {
		get { kvStore["healthCertificateInfoScreenShown25"] as Bool? ?? false }
		set { kvStore["healthCertificateInfoScreenShown25"] = newValue }
	}

    var healthCertifiedPersons: [HealthCertifiedPerson] {
        get { kvStore["healthCertifiedPersons"] as [HealthCertifiedPerson]? ?? [] }
        set { kvStore["healthCertifiedPersons"] = newValue }
    }

	var healthCertifiedPersonsVersion: Int? {
		get { kvStore["healthCertifiedPersonsVersion"] as Int? ?? nil }
		set { kvStore["healthCertifiedPersonsVersion"] = newValue }
	}

	var testCertificateRequests: [TestCertificateRequest] {
		get { kvStore["testCertificateRequests"] as [TestCertificateRequest]? ?? [] }
		set { kvStore["testCertificateRequests"] = newValue }
	}

	var lastSelectedValidationCountry: Country {
		get {
			let country = kvStore["lastSelectedValidationCountry"] as Country? ?? Country.defaultCountry()
			return Country(withCountryCodeFallback: country.id)
		}
		set { kvStore["lastSelectedValidationCountry"] = newValue }
	}

	var lastSelectedValidationDate: Date {
		get { kvStore["lastSelectedValidationDate"] as Date? ?? Date() }
		set { kvStore["lastSelectedValidationDate"] = newValue }
	}
	
	// MARK: - Protocol VaccinationCaching

	var vaccinationCertificateValueDataSets: VaccinationValueDataSets? {
		get { kvStore["vaccinationCertificateValueDataSets"] as VaccinationValueDataSets? ?? nil }
		set { kvStore["vaccinationCertificateValueDataSets"] = newValue }
	}
	
	// MARK: - Protocol HealthCertificateValidationCaching
	
	var validationOnboardedCountriesCache: HealthCertificateValidationOnboardedCountriesCache? {
		get {
			let countriesCache = kvStore["validationOnboardedCountriesCache"] as HealthCertificateValidationOnboardedCountriesCache? ?? nil
			guard let countries = countriesCache?.onboardedCountries,
				  let eTag = countriesCache?.lastOnboardedCountriesETag
			else {
				return nil
			}
			let mappedCountries = countries.map({ Country(withCountryCodeFallback: $0.id) })
			return HealthCertificateValidationOnboardedCountriesCache(onboardedCountries: mappedCountries, lastOnboardedCountriesETag: eTag)
		}
		set { kvStore["validationOnboardedCountriesCache"] = newValue }
	}
	
	var acceptanceRulesCache: ValidationRulesCache? {
		get { kvStore["acceptanceRulesCache"] as ValidationRulesCache? ?? nil }
		set { kvStore["acceptanceRulesCache"] = newValue }
	}
	
	var invalidationRulesCache: ValidationRulesCache? {
		get { kvStore["invalidationRulesCache"] as ValidationRulesCache? ?? nil }
		set { kvStore["invalidationRulesCache"] = newValue }
	}
	
	// MARK: - Protocol HealthCertificateBoosterNotificationCaching
	
	var boosterRulesCache: ValidationRulesCache? {
		get { kvStore["boosterRulesCache"] as ValidationRulesCache? ?? nil }
		set { kvStore["boosterRulesCache"] = newValue }
	}

	// MARK: - Protocol RecycleBinStoring

	private(set) lazy var recycleBinItemsSubject = CurrentValueSubject<Set<RecycleBinItem>, Never>(recycleBinItems)

	var recycleBinItems: Set<RecycleBinItem> {
		get { kvStore["recycleBinItems"] as Set<RecycleBinItem>? ?? [] }
		set {
			kvStore["recycleBinItems"] = newValue
			recycleBinItemsSubject.send(newValue)
		}
	}

	// MARK: - Non-Release Stuff
	
	#if !RELEASE

	// Settings from the debug menu.

	var fakeSQLiteError: Int32? {
		get { kvStore["fakeSQLiteError"] as Int32? }
		set { kvStore["fakeSQLiteError"] = newValue }
	}

	var mostRecentRiskCalculation: ENFRiskCalculation? {
		get { kvStore["mostRecentRiskCalculation"] as ENFRiskCalculation? }
		set { kvStore["mostRecentRiskCalculation"] = newValue }
	}

	var mostRecentRiskCalculationConfiguration: RiskCalculationConfiguration? {
		get { kvStore["mostRecentRiskCalculationConfiguration"] as RiskCalculationConfiguration? }
		set { kvStore["mostRecentRiskCalculationConfiguration"] = newValue }
	}

	var forceAPITokenAuthorization: Bool {
		get { kvStore["forceAPITokenAuthorization"] as Bool? ?? false }
		set { kvStore["forceAPITokenAuthorization"] = newValue }
	}
	
	var recentTraceLocationCheckedInto: DMRecentTraceLocationCheckedInto? {
		get { kvStore["recentTraceLocationCheckedInto"] as DMRecentTraceLocationCheckedInto? ?? nil }
		set { kvStore["recentTraceLocationCheckedInto"] = newValue }
	}

	#endif

	// MARK: - Internal

	static let encryptionKeyKeychainKey = "secureStoreDatabaseKey"
	let kvStore: SQLiteKeyValueStore
	let directoryURL: URL

}

extension SecureStore: EventRegistrationCaching {
	
	var wasRecentTraceWarningDownloadSuccessful: Bool {
		get { kvStore["wasRecentTraceWarningDownloadSuccessful"] as Bool? ?? false }
		set { kvStore["wasRecentTraceWarningDownloadSuccessful"] = newValue }
	}
	
	var checkinInfoScreenShown: Bool {
		get { kvStore["checkinInfoScreenShown"] as Bool? ?? false }
		set { kvStore["checkinInfoScreenShown"] = newValue }
	}
	
	var traceLocationsInfoScreenShown: Bool {
		get { kvStore["traceLocationsInfoScreenShown"] as Bool? ?? false }
		set { kvStore["traceLocationsInfoScreenShown"] = newValue }
	}
	
	var shouldAddCheckinToContactDiaryByDefault: Bool {
		get { kvStore["shouldAddCheckinToContactDiaryByDefault"] as Bool? ?? true }
		set { kvStore["shouldAddCheckinToContactDiaryByDefault"] = newValue }
	}
	
	var qrCodePosterTemplateMetadata: QRCodePosterTemplateMetadata? {
		get { kvStore["qrCodePosterTemplateMetadata"] as QRCodePosterTemplateMetadata? ?? nil }
		set { kvStore["qrCodePosterTemplateMetadata"] = newValue }
	}
}

extension SecureStore: WarnOthersTimeIntervalStoring {

	var warnOthersNotificationOneTimeInterval: TimeInterval {
		get { kvStore["warnOthersNotificationTimerOne"] as TimeInterval? ?? WarnOthersNotificationsTimeInterval.intervalOne }
		set { kvStore["warnOthersNotificationTimerOne"] = newValue }
	}

	var warnOthersNotificationTwoTimeInterval: TimeInterval {
		get { kvStore["warnOthersNotificationTimerTwo"] as TimeInterval? ?? WarnOthersNotificationsTimeInterval.intervalTwo }
		set { kvStore["warnOthersNotificationTimerTwo"] = newValue }
	}

}

extension SecureStore: DeviceTimeCheckStoring {
	var deviceTimeCheckResult: DeviceTimeCheck.TimeCheckResult {
		get { kvStore["deviceTimeCheckResult"] as DeviceTimeCheck.TimeCheckResult? ?? .correct }
		set { kvStore["deviceTimeCheckResult"] = newValue }
	}

	var deviceTimeLastStateChange: Date {
		get { kvStore["deviceTimeLastStateChange"] as Date? ?? Date() }
		set { kvStore["deviceTimeLastStateChange"] = newValue }
	}

	var wasDeviceTimeErrorShown: Bool {
		get { kvStore["wasDeviceTimeErrorShown"] as Bool? ?? false }
		set { kvStore["wasDeviceTimeErrorShown"] = newValue }
	}
}

extension SecureStore: AppFeaturesStoring {
	#if !RELEASE
	var dmKillDeviceTimeCheck: Bool {
		get { kvStore["dmKillDeviceTimeCheck"] as Bool? ?? false }
		set { kvStore["dmKillDeviceTimeCheck"] = newValue }
	}

	var unencryptedCheckinsEnabled: Bool {
		get { kvStore["unencryptedCheckinsEnabled"] as Bool? ?? false }
		set { kvStore["unencryptedCheckinsEnabled"] = newValue }
	}
	#endif
}

extension SecureStore: TicketValidationStoring {
	#if !RELEASE
	var skipAllowlistValidation: Bool {
		get { kvStore["skipAllowlistValidation"] as Bool? ?? false }
		set { kvStore["skipAllowlistValidation"] = newValue }
	}
	#endif
}

extension SecureStore: AppConfigCaching {
	var appConfigMetadata: AppConfigMetadata? {
		get { kvStore["appConfigMetadataV2"] as AppConfigMetadata? ?? nil }
		set { kvStore["appConfigMetadataV2"] = newValue }
	}
}

extension SecureStore: StatisticsCaching {
	var statistics: StatisticsMetadata? {
		get { kvStore["statistics"] as StatisticsMetadata? ?? nil }
		set { kvStore["statistics"] = newValue }
	}
}

extension SecureStore: LocalStatisticsCaching {
	var localStatistics: [LocalStatisticsMetadata] {
		get { kvStore["localStatistics"] as [LocalStatisticsMetadata]? ?? [] }
		set { kvStore["localStatistics"] = newValue }
	}
	
	var selectedLocalStatisticsRegions: [LocalStatisticsRegion] {
		get { kvStore["selectedLocalStatisticsDistricts"] as [LocalStatisticsRegion]? ?? [] }
		set { kvStore["selectedLocalStatisticsDistricts"] = newValue }
	}
}

extension SecureStore: PrivacyPreservingProviding {

	var isPrivacyPreservingAnalyticsConsentGiven: Bool {
		get { kvStore["isPrivacyPreservingAnalyticsConsentGiven"] as Bool? ?? false }
		set { kvStore["isPrivacyPreservingAnalyticsConsentGiven"] = newValue
			if newValue == false {
				userData = nil
			}
		}
	}

	var userData: UserMetadata? {
		get { kvStore["userMetadata"] as UserMetadata? ?? nil }
		set { kvStore["userMetadata"] = newValue
			Analytics.collect(.userData(.create(newValue)))
		}
	}

	var otpTokenEdus: OTPToken? {
		get { kvStore["otpToken"] as OTPToken? }
		set { kvStore["otpToken"] = newValue }
	}

	var otpEdusAuthorizationDate: Date? {
		get { kvStore["otpAuthorizationDate"] as Date? }
		set { kvStore["otpAuthorizationDate"] = newValue }
	}

	var ppacApiTokenEdus: TimestampedToken? {
		get { kvStore["ppacApiToken"] as TimestampedToken? }
		set { kvStore["ppacApiToken"] = newValue }
	}
}

extension SecureStore: ErrorLogProviding {
	
	var ppacApiTokenEls: TimestampedToken? {
		get { kvStore["ppacApiTokenEls"] as TimestampedToken? }
		set { kvStore["ppacApiTokenEls"] = newValue }
	}
	
	var otpTokenEls: OTPToken? {
		get { kvStore["otpTokenEls"] as OTPToken? }
		set { kvStore["otpTokenEls"] = newValue }
	}
	
	var otpElsAuthorizationDate: Date? {
		get { kvStore["otpElsAuthorizationDate"] as Date? }
		set { kvStore["otpElsAuthorizationDate"] = newValue }
	}
	
	#if !RELEASE
	var elsLoggingActiveAtStartup: Bool {
		get { kvStore["elsLoggingActiveAtStartup"] as Bool? ?? true }
		set { kvStore["elsLoggingActiveAtStartup"] = newValue }
	}
	#endif
}

extension SecureStore: ErrorLogUploadHistoryProviding {
	
	var elsUploadHistory: [ErrorLogUploadReceipt] {
		get { kvStore["elsHistory"] as [ErrorLogUploadReceipt]? ?? [ErrorLogUploadReceipt]() }
		set { kvStore["elsHistory"] = newValue }
	}
}

extension SecureStore: CoronaTestStoring {

	var pcrTest: PCRTest? {
		get { kvStore["pcrTest"] as PCRTest? }
		set { kvStore["pcrTest"] = newValue }
	}

	var antigenTest: AntigenTest? {
		get { kvStore["antigenTest"] as AntigenTest? }
		set { kvStore["antigenTest"] = newValue }
	}

	var unseenTestsCount: Int {
		get { kvStore["unseenTestsCount"] as Int? ?? 0 }
		set { kvStore["unseenTestsCount"] = newValue }
	}
}

extension SecureStore: CoronaTestStoringLegacy {

	var registrationToken: String? {
		get { kvStore["registrationToken"] as String? }
		set { kvStore["registrationToken"] = newValue }
	}

	var teleTan: String? {
		get { kvStore["teleTan"] as String? ?? "" }
		set { kvStore["teleTan"] = newValue }
	}

	var tan: String? {
		get { kvStore["tan"] as String? }
		set { kvStore["tan"] = newValue }
	}

	var testGUID: String? {
		get { kvStore["testGUID"] as String? ?? "" }
		set { kvStore["testGUID"] = newValue }
	}

	var devicePairingConsentAccept: Bool {
		get { kvStore["devicePairingConsentAccept"] as Bool? ?? false }
		set { kvStore["devicePairingConsentAccept"] = newValue }
	}

	var devicePairingConsentAcceptTimestamp: Int64? {
		get { kvStore["devicePairingConsentAcceptTimestamp"] as Int64? ?? 0 }
		set { kvStore["devicePairingConsentAcceptTimestamp"] = newValue }
	}

	var devicePairingSuccessfulTimestamp: Int64? {
		get { kvStore["devicePairingSuccessfulTimestamp"] as Int64? ?? 0 }
		set { kvStore["devicePairingSuccessfulTimestamp"] = newValue }
	}

	var testResultReceivedTimeStamp: Int64? {
		get { kvStore["testResultReceivedTimeStamp"] as Int64? }
		set { kvStore["testResultReceivedTimeStamp"] = newValue }
	}

	// this test registration date is for both TAN and QR submission
	var testRegistrationDate: Date? {
		get { kvStore["testRegistrationDate"] as Date? ?? nil }
		set { kvStore["testRegistrationDate"] = newValue }
	}

	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64? {
		get { kvStore["lastSuccessfulSubmitDiagnosisKeyTimestamp"] as Int64? }
		set { kvStore["lastSuccessfulSubmitDiagnosisKeyTimestamp"] = newValue }
	}

	var positiveTestResultWasShown: Bool {
		get { kvStore["warnOthersHasActiveTestResult"] as Bool? ?? false }
		set { kvStore["warnOthersHasActiveTestResult"] = newValue }
	}

	var isSubmissionConsentGiven: Bool {
		get { kvStore["isSubmissionConsentGiven"] as Bool? ?? false }
		set { kvStore["isSubmissionConsentGiven"] = newValue }
	}
}

extension SecureStore: DSCListCaching {

	var dscList: DSCListMetaData? {
		get { kvStore["DSCList"] as DSCListMetaData? }
		set { kvStore["DSCList"] = newValue }
	}
}
