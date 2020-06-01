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

import Foundation

protocol Store: AnyObject {
	var isOnboarded: Bool { get set }
	var dateLastExposureDetection: Date? { get set }
	var dateOfAcceptedPrivacyNotice: Date? { get set }
	var developerSubmissionBaseURLOverride: String? { get set }
	var developerDistributionBaseURLOverride: String? { get set }
	var developerVerificationBaseURLOverride: String? { get set }
	var teleTan: String? { get set }

	// A secret allowing the client to upload the diagnosisKey set.
	var tan: String? { get set }
	var testGUID: String? { get set }
	var devicePairingConsentAccept: Bool { get set }
	var devicePairingConsentAcceptTimestamp: Int64? { get set }
	var devicePairingSuccessfulTimestamp: Int64? { get set }
	var isAllowedToSubmitDiagnosisKeys: Bool { get set }

	var allowRiskChangesNotification: Bool { get set }
	var allowTestsStatusNotification: Bool { get set }

	var registrationToken: String? { get set }
	var hasSeenSubmissionExposureTutorial: Bool { get set }

	// Timestamp that represents the date at which
	// the user has received a test reult.
	var testResultReceivedTimeStamp: Int64? { get set }

	// Timestamp representing the last successful diagnosis keys submission.
	// This is needed to allow in the future delta submissions of diagnosis keys since the last submission.
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64? { get set }

	// The number of successful submissions to the CWA-submission backend service.
	var numberOfSuccesfulSubmissions: Int64? { get set }

	// Boolean representing the initial submit completed state.
	var initialSubmitCompleted: Bool { get set }

	// An integer value representing the timestamp when the user
	// accepted to submit his diagnosisKeys with the CWA submission service.
	var submitConsentAcceptTimestamp: Int64? { get set }

	// A boolean storing if the user has confirmed to submit
	// his diagnosiskeys to the CWA submission service.
	var submitConsentAccept: Bool { get set }

	func clearAll()
}

// The `DevelopmentStore` class implements the `Store` protocol that defines all required storage attributes.
/// This class needs to be replaced with an implementation that persists all attributes in an encrypted SQLite database.
final class DevelopmentStore: Store {
	func clearAll() {
		// UserDefaults.standard.removeObject(forKey: "isOnboarded")
		UserDefaults.standard.removeObject(forKey: "dateLastExposureDetection")
		UserDefaults.standard.removeObject(forKey: "dateOfAcceptedPrivacyNotice")
		UserDefaults.standard.removeObject(forKey: "allowsCellularUse")
		UserDefaults.standard.removeObject(forKey: "developerSubmissionBaseURLOverride")
		UserDefaults.standard.removeObject(forKey: "developerDistributionBaseURLOverride")
		UserDefaults.standard.removeObject(forKey: "developerVerificationBaseURLOverride")
		UserDefaults.standard.removeObject(forKey: "teleTan")
		UserDefaults.standard.removeObject(forKey: "testGUID")
		UserDefaults.standard.removeObject(forKey: "devicePairingConsentAccept")
		UserDefaults.standard.removeObject(forKey: "devicePairingConsentAcceptTimestamp")
		UserDefaults.standard.removeObject(forKey: "devicePairingSuccessfulTimestamp")
		UserDefaults.standard.removeObject(forKey: "isAllowedToSubmitDiagnosisKeys")
		UserDefaults.standard.removeObject(forKey: "registrationToken")
		log(message: "Flushed DevelopmentStore", level: .info)
	}

	/// Manually remove all keys that are saved through the `Store` protocol.
	/// We do not loop here since this may destroys keys that are not managed through this class.
	static func flush() {
		// UserDefaults.standard.removeObject(forKey: "isOnboarded")
		UserDefaults.standard.removeObject(forKey: "dateLastExposureDetection")
		UserDefaults.standard.removeObject(forKey: "dateOfAcceptedPrivacyNotice")
		UserDefaults.standard.removeObject(forKey: "allowsCellularUse")
		// UserDefaults.standard.removeObject(forKey: "developerSubmissionBaseURLOverride")
		// UserDefaults.standard.removeObject(forKey: "developerDistributionBaseURLOverride")
		// UserDefaults.standard.removeObject(forKey: "developerVerificationBaseURLOverride")
		UserDefaults.standard.removeObject(forKey: "teleTan")
		UserDefaults.standard.removeObject(forKey: "testGUID")
		UserDefaults.standard.removeObject(forKey: "devicePairingConsentAccept")
		UserDefaults.standard.removeObject(forKey: "devicePairingConsentAcceptTimestamp")
		UserDefaults.standard.removeObject(forKey: "devicePairingSuccessfulTimestamp")
		UserDefaults.standard.removeObject(forKey: "isAllowedToSubmitDiagnosisKeys")
		UserDefaults.standard.removeObject(forKey: "registrationToken")
		log(message: "Flushed DevelopmentStore", level: .info)
	}

	// TODO: Implement handlers for these.

	@PersistedAndPublished(
		key: "testResultReceivedTimeStamp",
		notificationName: Notification.Name.testResultReceivedTimeStampDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "testResultReceivedTimeStamp") as? Int64
	)
	var testResultReceivedTimeStamp: Int64?

	@PersistedAndPublished(
		key: "lastSuccessfulSubmitDiagnosisKeyTimestamp",
		notificationName: Notification.Name.lastSuccessfulSubmitDiagnosisKeyTimestampDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "lastSuccessfulSubmitDiagnosisKeyTimestamp") as? Int64
	)
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?

	@PersistedAndPublished(
		key: "numberOfSuccesfulSubmissions",
		notificationName: Notification.Name.numberOfSuccesfulSubmissionsDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "numberOfSuccesfulSubmissions") as? Int64
	)
	var numberOfSuccesfulSubmissions: Int64?

	@PersistedAndPublished(
		key: "initialSubmitCompleted",
		notificationName: Notification.Name.initialSubmitCompletedDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "initialSubmitCompleted") as? Bool ?? false
	)
	var initialSubmitCompleted: Bool

	@PersistedAndPublished(
		key: "submitConsentAcceptTimestamp",
		notificationName: Notification.Name.submitConsentAcceptTimestampDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "submitConsentAcceptTimestamp") as? Int64
	)
	var submitConsentAcceptTimestamp: Int64?

	@PersistedAndPublished(
		key: "submitConsentAccept",
		notificationName: Notification.Name.submitConsentAcceptDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "submitConsentAccept") as? Bool ?? false
	)
	var submitConsentAccept: Bool

	@PersistedAndPublished(
		key: "registrationToken",
		notificationName: Notification.Name.registrationTokenDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "registrationToken") as? String
	)
	var registrationToken: String?

	@PersistedAndPublished(
		key: "hasSeenSubmissionExposureTutorial",
		notificationName: Notification.Name.hasSeenSubmissionExposureTutorialDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "hasSeenSubmissionExposureTutorial") as? Bool ?? false
	)
	var hasSeenSubmissionExposureTutorial: Bool

	@PersistedAndPublished(
		key: "teleTan",
		notificationName: Notification.Name.teleTanDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "teleTan") as? String
	)
	var teleTan: String?

	@PersistedAndPublished(
		key: "tan",
		notificationName: Notification.Name.tanDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "tan") as? String
	)
	var tan: String?

	@PersistedAndPublished(
		key: "testGUID",
		notificationName: Notification.Name.testGUIDDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "testGUID") as? String
	)
	var testGUID: String?

	@PersistedAndPublished(
		key: "devicePairingConsentAccept",
		notificationName: Notification.Name.devicePairingConsentAcceptDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "devicePairingConsentAccept") as? Bool ?? false
	)
	var devicePairingConsentAccept: Bool

	@PersistedAndPublished(
		key: "devicePairingConsentAcceptTimestamp",
		notificationName: Notification.Name.devicePairingConsentAcceptTimestampDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "devicePairingConsentAcceptTimestamp") as? Int64
	)
	var devicePairingConsentAcceptTimestamp: Int64?

	@PersistedAndPublished(
		key: "devicePairingSuccessfulTimestamp",
		notificationName: Notification.Name.devicePairingSuccessfulTimestampDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "devicePairingSuccessfulTimestamp") as? Int64
	)
	var devicePairingSuccessfulTimestamp: Int64?

	@PersistedAndPublished(
		key: "isAllowedToSubmitDiagnosisKeys",
		notificationName: Notification.Name.isAllowedToSubmitDiagnosisKeysDidChange,
		defaultValue: UserDefaults
			.standard
			.object(forKey: "isAllowedToSubmitDiagnosisKeys") as? Bool ?? false
	)
	var isAllowedToSubmitDiagnosisKeys: Bool

	@PersistedAndPublished(
		key: "isOnboarded",
		notificationName: Notification.Name.isOnboardedDidChange,
		defaultValue: (UserDefaults.standard.object(forKey: "isOnboarded") as? String) == "YES"
	)
	var isOnboarded: Bool

	@PersistedAndPublished(
		key: "dateLastExposureDetection",
		notificationName: Notification.Name.dateLastExposureDetectionDidChange
	)
	var dateLastExposureDetection: Date?

	@PersistedAndPublished(
		key: "dateOfAcceptedPrivacyNotice",
		notificationName: Notification.Name.dateOfAcceptedPrivacyNoticeDidChange
	)
	var dateOfAcceptedPrivacyNotice: Date?

	@PersistedAndPublished(
		key: "developerSubmissionBaseURLOverride",
		notificationName: Notification.Name.developerSubmissionBaseURLOverrideDidChange
	)
	var developerSubmissionBaseURLOverride: String?

	@PersistedAndPublished(
		key: "developerDistributionBaseURLOverride",
		notificationName: Notification.Name.developerDistributionBaseURLOverrideDidChange
	)
	var developerDistributionBaseURLOverride: String?

	@PersistedAndPublished(
		key: "developerVerificationBaseURLOverride",
		notificationName: Notification.Name.developerVerificationBaseURLOverrideDidChange
	)
	var developerVerificationBaseURLOverride: String?

	@PersistedAndPublished(
		key: "allowRiskChangesNotification",
		notificationName: Notification.Name.allowRiskChangesNotificationDidChange,
		defaultValue: true
	)
	var allowRiskChangesNotification: Bool

	@PersistedAndPublished(
		key: "allowTestsStatusNotification",
		notificationName: Notification.Name.allowTestsStatusNotificationDidChange,
		defaultValue: true
	)
	var allowTestsStatusNotification: Bool
}

/// The `SecureStore` class implements the `Store` protocol that defines all required storage attributes.
/// It uses an SQLite Database that still needs to be encrypted
final class SecureStore: Store {
	private let fileURL: URL
	private let kvStore: SQLiteKeyValueStore

	init() {
		do {
			fileURL = try FileManager.default
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("secureStore.sqlite")
		} catch {
			// swiftlint:disable:next force_unwrapping
			fileURL = URL(string: "file::memory:")!
		}
		kvStore = SQLiteKeyValueStore(with: fileURL)
	}

	func flush() {
		kvStore.flush()
	}

	func clearAll() {
		kvStore.clearAll()
	}

	var testResultReceivedTimeStamp: Int64? {
		get { kvStore["testResultReceivedTimeStamp"] as Int64? }
		set { kvStore["testResultReceivedTimeStamp"] = newValue
			NotificationCenter.default.post(name: Notification.Name.testResultReceivedTimeStampDidChange, object: nil)
		}
	}

	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64? {
		get { kvStore["lastSuccessfulSubmitDiagnosisKeyTimestamp"] as Int64? }
		set { kvStore["lastSuccessfulSubmitDiagnosisKeyTimestamp"] = newValue
			NotificationCenter.default.post(name: Notification.Name.lastSuccessfulSubmitDiagnosisKeyTimestampDidChange, object: nil)
		}
	}

	var numberOfSuccesfulSubmissions: Int64? {
		get { kvStore["numberOfSuccesfulSubmissions"] as Int64? ?? 0 }
		set { kvStore["numberOfSuccesfulSubmissions"] = newValue
			NotificationCenter.default.post(name: Notification.Name.numberOfSuccesfulSubmissionsDidChange, object: nil)
		}
	}

	var initialSubmitCompleted: Bool {
		get { kvStore["initialSubmitCompleted"] as Bool? ?? false }
		set { kvStore["initialSubmitCompleted"] = newValue
			NotificationCenter.default.post(name: Notification.Name.initialSubmitCompletedDidChange, object: nil)
		}
	}

	var submitConsentAcceptTimestamp: Int64? {
		get { kvStore["submitConsentAcceptTimestamp"] as Int64? ?? 0 }
		set { kvStore["submitConsentAcceptTimestamp"] = newValue
			NotificationCenter.default.post(name: Notification.Name.lastSuccessfulSubmitDiagnosisKeyTimestampDidChange, object: nil)
		}
	}

	var submitConsentAccept: Bool {
		get { kvStore["submitConsentAccept"] as Bool? ?? false }
		set { kvStore["submitConsentAccept"] = newValue
			NotificationCenter.default.post(name: Notification.Name.submitConsentAcceptDidChange, object: nil)
		}
	}

	var registrationToken: String? {
		get { kvStore["registrationToken"] as String? }
		set { kvStore["registrationToken"] = newValue
			NotificationCenter.default.post(name: Notification.Name.registrationTokenDidChange, object: nil)
		}
	}

	var teleTan: String? {
		get { kvStore["teleTan"] as String? ?? "" }
		set { kvStore["teleTan"] = newValue
			NotificationCenter.default.post(name: Notification.Name.teleTanDidChange, object: nil)
		}
	}

	var tan: String? {
		get { kvStore["tan"] as String? ?? "" }
		set { kvStore["tan"] = newValue
			NotificationCenter.default.post(name: Notification.Name.tanDidChange, object: nil)
		}
	}

	var testGUID: String? {
		get { kvStore["testGUID"] as String? ?? "" }
		set { kvStore["testGUID"] = newValue
			NotificationCenter.default.post(name: Notification.Name.testGUIDDidChange, object: nil)
		}
	}

	var devicePairingConsentAccept: Bool {
		get { kvStore["devicePairingConsentAccept"] as Bool? ?? false }
		set { kvStore["devicePairingConsentAccept"] = newValue
			NotificationCenter.default.post(name: Notification.Name.devicePairingConsentAcceptDidChange, object: nil)
		}
	}

	var devicePairingConsentAcceptTimestamp: Int64? {
		get { kvStore["devicePairingConsentAcceptTimestamp"] as Int64? ?? 0 }
		set { kvStore["devicePairingConsentAcceptTimestamp"] = newValue
			NotificationCenter.default.post(name: Notification.Name.devicePairingConsentAcceptTimestampDidChange, object: nil)
		}
	}

	var devicePairingSuccessfulTimestamp: Int64? {
		get { kvStore["devicePairingSuccessfulTimestamp"] as Int64? ?? 0 }
		set { kvStore["devicePairingSuccessfulTimestamp"] = newValue
			NotificationCenter.default.post(name: Notification.Name.devicePairingSuccessfulTimestampDidChange, object: nil)
		}
	}

	var isAllowedToSubmitDiagnosisKeys: Bool {
		get { kvStore["isAllowedToSubmitDiagnosisKeys"] as Bool? ?? false }
		set { kvStore["isAllowedToSubmitDiagnosisKeys"] = newValue
			NotificationCenter.default.post(name: Notification.Name.isAllowedToSubmitDiagnosisKeysDidChange, object: nil)
		}
	}

	var isOnboarded: Bool {
		get {
			kvStore["isOnboarded"] as Bool? ?? false
		}
		set {
			kvStore["isOnboarded"] = newValue
			NotificationCenter.default.post(name: Notification.Name.isOnboardedDidChange, object: nil)
		}
	}

	var dateLastExposureDetection: Date? {
		get { kvStore["dateLastExposureDetection"] as Date? ?? nil }
		set { kvStore["dateLastExposureDetection"] = newValue
			NotificationCenter.default.post(name: Notification.Name.dateLastExposureDetectionDidChange, object: nil)
		}
	}

	var dateOfAcceptedPrivacyNotice: Date? {
		get { kvStore["dateOfAcceptedPrivacyNotice"] as Date? ?? nil }
		set { kvStore["dateOfAcceptedPrivacyNotice"] = newValue
			NotificationCenter.default.post(name: Notification.Name.dateOfAcceptedPrivacyNoticeDidChange, object: nil)
		}
	}

	var hasSeenSubmissionExposureTutorial: Bool {
		get { kvStore["hasSeenSubmissionExposureTutorial"] as Bool? ?? false }
		set { kvStore["hasSeenSubmissionExposureTutorial"] = newValue
			NotificationCenter.default.post(name: Notification.Name.hasSeenSubmissionExposureTutorialDidChange, object: nil)
		}
	}

	var developerSubmissionBaseURLOverride: String? {
		get { kvStore["developerSubmissionBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerSubmissionBaseURLOverride"] = newValue
			NotificationCenter.default.post(name: Notification.Name.developerSubmissionBaseURLOverrideDidChange, object: nil)
		}
	}

	var developerDistributionBaseURLOverride: String? {
		get { kvStore["developerDistributionBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerDistributionBaseURLOverride"] = newValue
			NotificationCenter.default.post(name: Notification.Name.developerDistributionBaseURLOverrideDidChange, object: nil)
		}
	}

	var developerVerificationBaseURLOverride: String? {
		get { kvStore["developerVerificationBaseURLOverride"] as String? ?? nil }
		set { kvStore["developerVerificationBaseURLOverride"] = newValue
			NotificationCenter.default.post(name: Notification.Name.developerVerificationBaseURLOverrideDidChange, object: nil)
		}
	}

	var allowRiskChangesNotification: Bool {
		get {
			kvStore["allowRiskChangesNotification"] as Bool? ?? true
		}
		set {
			kvStore["allowRiskChangesNotification"] = newValue
			NotificationCenter.default.post(name: Notification.Name.allowRiskChangesNotificationDidChange, object: nil)
		}
	}

	var allowTestsStatusNotification: Bool {
		get {
			kvStore["allowTestsStatusNotification"] as Bool? ?? true
		}
		set {
			kvStore["allowTestsStatusNotification"] = newValue
			NotificationCenter.default.post(name: Notification.Name.allowTestsStatusNotificationDidChange, object: nil)
		}
	}
}
