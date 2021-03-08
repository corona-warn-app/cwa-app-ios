//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

/// The `SecureStore` class implements the `Store` protocol that defines all required storage attributes.
/// It uses an SQLite Database that still needs to be encrypted
final class SecureStore: Store {

	// MARK: - Init

	init(
		at directoryURL: URL,
		key: String,
		serverEnvironment: ServerEnvironment
	) throws {
		self.directoryURL = directoryURL
		self.kvStore = try SQLiteKeyValueStore(with: directoryURL, key: key)
		self.serverEnvironment = serverEnvironment
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
	func clearAll(key: String?) {
		do {
			try kvStore.clearAll(key: key)
		} catch {
			Log.error("kv store error", log: .localData, error: error)
		}
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

	var numberOfSuccesfulSubmissions: Int64? {
		get { kvStore["numberOfSuccesfulSubmissions"] as Int64? ?? 0 }
		set { kvStore["numberOfSuccesfulSubmissions"] = newValue }
	}

	var initialSubmitCompleted: Bool {
		get { kvStore["initialSubmitCompleted"] as Bool? ?? false }
		set { kvStore["initialSubmitCompleted"] = newValue }
	}

	var exposureActivationConsentAcceptTimestamp: Int64? {
		get { kvStore["exposureActivationConsentAcceptTimestamp"] as Int64? ?? 0 }
		set { kvStore["exposureActivationConsentAcceptTimestamp"] = newValue }
	}

	var exposureActivationConsentAccept: Bool {
		get { kvStore["exposureActivationConsentAccept"] as Bool? ?? false }
		set { kvStore["exposureActivationConsentAccept"] = newValue }
	}

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

	var hasSeenSubmissionExposureTutorial: Bool {
		get { kvStore["hasSeenSubmissionExposureTutorial"] as Bool? ?? false }
		set { kvStore["hasSeenSubmissionExposureTutorial"] = newValue }
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

	var allowRiskChangesNotification: Bool {
		get { kvStore["allowRiskChangesNotification"] as Bool? ?? true }
		set { kvStore["allowRiskChangesNotification"] = newValue }
	}

	var allowTestsStatusNotification: Bool {
		get { kvStore["allowTestsStatusNotification"] as Bool? ?? true }
		set { kvStore["allowTestsStatusNotification"] = newValue }
	}

	var appInstallationDate: Date? {
		get { kvStore["appInstallationDate"] as Date? }
		set { kvStore["appInstallationDate"] = newValue }
	}

	var riskCalculationResult: RiskCalculationResult? {
		get { kvStore["riskCalculationResult"] as RiskCalculationResult? ?? nil }
		set { kvStore["riskCalculationResult"] = newValue }
	}

	var dateOfConversionToHighRisk: Date? {
		get { kvStore["dateOfConversionToHighRisk"] as Date? ?? nil }
		set { kvStore["dateOfConversionToHighRisk"] = newValue }
	}

	var shouldShowRiskStatusLoweredAlert: Bool {
		get { kvStore["shouldShowRiskStatusLoweredAlert"] as Bool? ?? false }
		set { kvStore["shouldShowRiskStatusLoweredAlert"] = newValue }
	}

	var userNeedsToBeInformedAboutHowRiskDetectionWorks: Bool {
		get { kvStore["userNeedsToBeInformedAboutHowRiskDetectionWorks"] as Bool? ?? true }
		set { kvStore["userNeedsToBeInformedAboutHowRiskDetectionWorks"] = newValue }
	}

	var lastBackgroundFakeRequest: Date {
		get { kvStore["lastBackgroundFakeRequest"] as Date? ?? Date() }
		set { kvStore["lastBackgroundFakeRequest"] = newValue }
	}

	var firstPlaybookExecution: Date? {
		get { kvStore["firstPlaybookExecution"] as Date? }
		set { kvStore["firstPlaybookExecution"] = newValue }
	}

	var isAllowedToPerformBackgroundFakeRequests: Bool {
		get { kvStore["shouldPerformBackgroundFakeRequests"] as Bool? ?? false }
		set { kvStore["shouldPerformBackgroundFakeRequests"] = newValue }
	}

	var selectedServerEnvironment: ServerEnvironmentData {
		get { kvStore["selectedServerEnvironment"] as ServerEnvironmentData? ?? serverEnvironment.defaultEnvironment() }
		set { kvStore["selectedServerEnvironment"] = newValue }
	}

	var wasRecentDayKeyDownloadSuccessful: Bool {
		get { kvStore["wasRecentDayKeyDownloadSuccessful"] as Bool? ?? false }
		set { kvStore["wasRecentDayKeyDownloadSuccessful"] = newValue }
	}

	var wasRecentHourKeyDownloadSuccessful: Bool {
		get { kvStore["wasRecentHourKeyDownloadSuccessful"] as Bool? ?? false }
		set { kvStore["wasRecentHourKeyDownloadSuccessful"] = newValue }
    }

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

	var lastKeyPackageDownloadDate: Date {
		get { kvStore["lastKeyPackageDownloadDate"] as Date? ?? .distantPast }
		set { kvStore["lastKeyPackageDownloadDate"] = newValue }
	}

	var isSubmissionConsentGiven: Bool {
		get { kvStore["isSubmissionConsentGiven"] as Bool? ?? false }
		set { kvStore["isSubmissionConsentGiven"] = newValue }
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

	var submissionCountries: [Country] {
		get { kvStore["submissionCountries"] as [Country]? ?? [.defaultCountry()] }
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

	#if !RELEASE

	// Settings from the debug menu.

	var fakeSQLiteError: Int32? {
		get { kvStore["fakeSQLiteError"] as Int32? }
		set { kvStore["fakeSQLiteError"] = newValue }
	}

	var dmKillDeviceTimeCheck: Bool {
		get { kvStore["dmKillDeviceTimeCheck"] as Bool? ?? false }
		set { kvStore["dmKillDeviceTimeCheck"] = newValue }
	}

	var mostRecentRiskCalculation: RiskCalculation? {
		get { kvStore["mostRecentRiskCalculation"] as RiskCalculation? }
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

	#endif

	let kvStore: SQLiteKeyValueStore

	// MARK: - Private

	private let directoryURL: URL
	private var serverEnvironment: ServerEnvironment

}

extension SecureStore {

	var warnOthersNotificationOneTimer: TimeInterval {
		get { kvStore["warnOthersNotificationTimerOne"] as TimeInterval? ?? WarnOthersNotificationsTimeInterval.intervalOne }
		set { kvStore["warnOthersNotificationTimerOne"] = newValue }
	}

	var warnOthersNotificationTwoTimer: TimeInterval {
		get { kvStore["warnOthersNotificationTimerTwo"] as TimeInterval? ?? WarnOthersNotificationsTimeInterval.intervalTwo }
		set { kvStore["warnOthersNotificationTimerTwo"] = newValue }
	}

	var positiveTestResultWasShown: Bool {
		get { kvStore["warnOthersHasActiveTestResult"] as Bool? ?? false }
		set { kvStore["warnOthersHasActiveTestResult"] = newValue }
	}

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

extension SecureStore: PrivacyPreservingProviding {

	var isPrivacyPreservingAnalyticsConsentGiven: Bool {
		get { kvStore["isPrivacyPreservingAnalyticsConsentGiven"] as Bool? ?? false }
		set { kvStore["isPrivacyPreservingAnalyticsConsentGiven"] = newValue
			userData = nil
		}
	}

	var userData: UserMetadata? {
		get { kvStore["userMetadata"] as UserMetadata? ?? nil }
		set { kvStore["userMetadata"] = newValue
			Analytics.collect(.userData(.create(newValue)))
		}
	}

	var otpToken: OTPToken? {
		get { kvStore["otpToken"] as OTPToken? }
		set { kvStore["otpToken"] = newValue }
	}

	var otpAuthorizationDate: Date? {
		get { kvStore["otpAuthorizationDate"] as Date? }
		set { kvStore["otpAuthorizationDate"] = newValue }
	}

	var ppacApiToken: TimestampedToken? {
		get { kvStore["ppacApiToken"] as TimestampedToken? }
		set { kvStore["ppacApiToken"] = newValue }
	}
}

extension SecureStore {

	static let keychainDatabaseKey = "secureStoreDatabaseKey"

	convenience init(subDirectory: String, serverEnvironment: ServerEnvironment) {
		self.init(subDirectory: subDirectory, isRetry: false, serverEnvironment: serverEnvironment)
	}

	private convenience init(subDirectory: String, isRetry: Bool, serverEnvironment: ServerEnvironment) {
		// swiftlint:disable:next force_try
		let keychain = try! KeychainHelper()
		do {
			let directoryURL = try SecureStore.databaseDirectory(at: subDirectory)
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: directoryURL.path) {
				// fetch existing key from keychain or generate a new one
				let key: String
				if let keyData = keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey) {
					#if DEBUG
					if isUITesting, ProcessInfo.processInfo.arguments.contains(UITestingParameters.SecureStoreHandling.simulateMismatchingKey.rawValue) {
						// injecting a wrong key to simulate a mismatch, e.g. because of backup restoration or other reasons
						key = "wrong 🔑"
						try self.init(at: directoryURL, key: key, serverEnvironment: serverEnvironment)
						return
					}
					#endif

					key = String(decoding: keyData, as: UTF8.self)
				} else {
					key = try keychain.generateDatabaseKey()
				}
				try self.init(at: directoryURL, key: key, serverEnvironment: serverEnvironment)
			} else {
				try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
				let key = try keychain.generateDatabaseKey()
				try self.init(at: directoryURL, key: key, serverEnvironment: serverEnvironment)
			}
		} catch is SQLiteStoreError where isRetry == false {
			SecureStore.performHardDatabaseReset(at: subDirectory)
			self.init(subDirectory: subDirectory, isRetry: true, serverEnvironment: serverEnvironment)
		} catch {
			fatalError("Creating the Database failed (\(error)")
		}
	}

	private static func databaseDirectory(at subDirectory: String) throws -> URL {
		try FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(subDirectory)
	}

	/// Last Resort option.
	///
	/// This function clears the existing database key and removes any existing databases.
	private static func performHardDatabaseReset(at path: String) {
		do {
			Log.info("⚠️ performing hard database reset ⚠️", log: .localData)
			// remove database key
			try KeychainHelper().clearInKeychain(key: SecureStore.keychainDatabaseKey)

			// remove database
			let directoryURL = try databaseDirectory(at: path)
			try FileManager.default.removeItem(at: directoryURL)
		} catch {
			fatalError("Reset failure: \(error.localizedDescription)")
		}
	}
}
