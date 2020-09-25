//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation

/// The `SecureStore` class implements the `Store` protocol that defines all required storage attributes.
/// It uses an SQLite Database that still needs to be encrypted
final class SecureStore: Store {

	// MARK: - Static.

	private let directoryURL: URL
	private let kvStore: SQLiteKeyValueStore

	init(at directoryURL: URL, key: String) throws {
		self.directoryURL = directoryURL
		self.kvStore = try SQLiteKeyValueStore(with: directoryURL, key: key)
	}

	/// Removes most key/value pairs.
	///
	/// Keys whose values are not removed:
	/// * `developerSubmissionBaseURLOverride`
	/// * `developerDistributionBaseURLOverride`
	/// * `developerVerificationBaseURLOverride`
	///
	/// - Note: This is just a wrapper to the `SQLiteKeyValueStore:flush` call
	func flush() {
		try? kvStore.flush()
	}

	/// Database reset & re-initialization with a given key
	/// - Parameter key: the key for the new database; if no key is given, no new database will be created
	///
	/// - Note: This is just a wrapper to the `SQLiteKeyValueStore:clearAll:` call
	func clearAll(key: String?) {
		try? kvStore.clearAll(key: key)
	}
	
	var testResultReceivedTimeStamp: Int64? {
		get { kvStore["testResultReceivedTimeStamp"] as Int64? }
		set { kvStore["testResultReceivedTimeStamp"] = newValue }
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

	var isAllowedToSubmitDiagnosisKeys: Bool {
		get { kvStore["isAllowedToSubmitDiagnosisKeys"] as Bool? ?? false }
		set { kvStore["isAllowedToSubmitDiagnosisKeys"] = newValue }
	}

	var isOnboarded: Bool {
		get { kvStore["isOnboarded"] as Bool? ?? false }
		set { kvStore["isOnboarded"] = newValue }
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

	var tracingStatusHistory: TracingStatusHistory {
		get {
			guard let historyData = kvStore["tracingStatusHistory"] else {
				return []
			}
			return (try? TracingStatusHistory.from(data: historyData)) ?? []
		}
		set {
			kvStore["tracingStatusHistory"] = try? newValue.JSONData()
		}
	}

	var summary: SummaryMetadata? {
		get { kvStore["previousSummaryMetadata"] as SummaryMetadata? ?? nil }
		set { kvStore["previousSummaryMetadata"] = newValue }
	}

	var hourlyFetchingEnabled: Bool {
		get { kvStore["hourlyFetchingEnabled"] as Bool? ?? false }
		set { kvStore["hourlyFetchingEnabled"] = newValue }
	}

	var previousRiskLevel: EitherLowOrIncreasedRiskLevel? {
		get {
			guard let value = kvStore["previousRiskLevel"] as Int? else {
				return nil
			}
			return EitherLowOrIncreasedRiskLevel(rawValue: value)
		}
		set { kvStore["previousRiskLevel"] = newValue?.rawValue }
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

	var serverEnvironment: ServerEnvironment {
		get { kvStore["serverEnvironment"] as ServerEnvironment? ?? LocalServerEnvironment.defaultEnvironment() }
		set { kvStore["serverEnvironment"] = newValue }
	}

}


extension SecureStore {

	static let keychainDatabaseKey = "secureStoreDatabaseKey"

	convenience init(subDirectory: String) {
		self.init(subDirectory: subDirectory, isRetry: false)
	}

	private convenience init(subDirectory: String, isRetry: Bool) {
		// swiftlint:disable:next force_try
		let keychain = try! KeychainHelper()

		do {
			let directoryURL = try SecureStore.databaseDirectory(at: subDirectory)
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: directoryURL.path) {
				// fetch existing key from keychain or generate a new one
				let key: String
				if let keyData = keychain.loadFromKeychain(key: SecureStore.keychainDatabaseKey) {
					#if UITESTING // enabled in UI tests
					if ProcessInfo.processInfo.arguments.contains(UITestingParameters.SecureStoreHandling.simulateMismatchingKey.rawValue) {
						// injecting a wrong key to simulate a mismatch, e.g. because of backup restoration or other reasons
						key = "wrong 🔑"
					} else {
						key = String(decoding: keyData, as: UTF8.self)
					}
					#else
					key = String(decoding: keyData, as: UTF8.self)
					#endif
				} else {
					key = try keychain.generateDatabaseKey()
				}
				try self.init(at: directoryURL, key: key)
			} else {
				try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
				let key = try keychain.generateDatabaseKey()
				try self.init(at: directoryURL, key: key)
			}
		} catch is SQLiteStoreError where isRetry == false {
			SecureStore.performHardDatabaseReset(at: subDirectory)
			self.init(subDirectory: subDirectory, isRetry: true)
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
			log(message: "⚠️ performing hard database reset ⚠️")
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
