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
import ExposureNotification

enum EitherLowOrIncreasedRiskLevel: Int {
	case low = 0
	case increased = 1_000 // so that increased > low + we have enough reserved values
}

extension EitherLowOrIncreasedRiskLevel {
	init?(with risk: RiskLevel) {
		switch risk {
		case .low:
			self = .low
		case .increased:
			self = .increased
		default:
			return nil
		}
	}
}

protocol Store: AnyObject {
	var isOnboarded: Bool { get set }
	var dateOfAcceptedPrivacyNotice: Date? { get set }
	var developerSubmissionBaseURLOverride: String? { get set }
	var developerDistributionBaseURLOverride: String? { get set }
	var developerVerificationBaseURLOverride: String? { get set }
	var teleTan: String? { get set }
	var hourlyFetchingEnabled: Bool { get set }

	// A secret allowing the client to upload the diagnosisKey set.
	var tan: String? { get set }
	var testGUID: String? { get set }
	var devicePairingConsentAccept: Bool { get set }
	var devicePairingConsentAcceptTimestamp: Int64? { get set }
	var devicePairingSuccessfulTimestamp: Int64? { get set }
	var isAllowedToSubmitDiagnosisKeys: Bool { get set }

	var allowRiskChangesNotification: Bool { get set }
	var allowTestsStatusNotification: Bool { get set }

	var summary: SummaryMetadata? { get set }

	// last successful recieved low or high risk level
	var previousRiskLevel: EitherLowOrIncreasedRiskLevel? { get set }

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
	var exposureActivationConsentAcceptTimestamp: Int64? { get set }

	// A boolean storing if the user has confirmed to submit
	// his diagnosiskeys to the CWA submission service.
	var exposureActivationConsentAccept: Bool { get set }

	var tracingStatusHistory: TracingStatusHistory { get set }

	var lastCheckedVersion: String? { get set }

	func clearAll(key: String?)
}


/// The `SecureStore` class implements the `Store` protocol that defines all required storage attributes.
/// It uses an SQLite Database that still needs to be encrypted
final class SecureStore: Store {
	private let directoryURL: URL?
	private let kvStore: SQLiteKeyValueStore

	init(at directoryURL: URL?, key: String) {
		self.directoryURL = directoryURL
		kvStore = SQLiteKeyValueStore(with: directoryURL, key: key)
	}

	func flush() {
		kvStore.flush()
	}

	func clearAll(key: String?) {
		kvStore.clearAll(key: key)
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
		get { kvStore["tan"] as String? ?? "" }
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

	var lastCheckedVersion: String? {
		get { kvStore["lastCheckedVersion"] as String? ?? "0.0.0" }
		set { kvStore["lastCheckedVersion"] = newValue }
	}
}

struct CodableExposureDetectionSummary: Codable {
	let daysSinceLastExposure: Int
	let matchedKeyCount: UInt64
	let maximumRiskScore: ENRiskScore
	let maximumRiskScoreFullRange: Int
	/// An array that contains the duration, in seconds, at certain attenuations, using an aggregated maximum exposures of 30 minutes.
	///
	/// Its values are adjusted based on the metadata in `ENExposureConfiguration`
	/// - see also: [Apple Documentation](https://developer.apple.com/documentation/exposurenotification/enexposuredetectionsummary/3586324-metadata)
	let configuredAttenuationDurations: [Double]

	init(
		daysSinceLastExposure: Int,
		matchedKeyCount: UInt64,
		maximumRiskScore: ENRiskScore,
		attenuationDurations: [Double],
		maximumRiskScoreFullRange: Int
	) {
		self.daysSinceLastExposure = daysSinceLastExposure
		self.matchedKeyCount = matchedKeyCount
		self.maximumRiskScore = maximumRiskScore
		self.configuredAttenuationDurations = attenuationDurations
		self.maximumRiskScoreFullRange = maximumRiskScoreFullRange
	}

	init?(with summary: ENExposureDetectionSummary?) {
		guard let summary = summary else {
			return nil
		}
		self.init(with: summary)
	}

	init(with summary: ENExposureDetectionSummary) {
		self.daysSinceLastExposure = summary.daysSinceLastExposure
		self.matchedKeyCount = summary.matchedKeyCount
		self.maximumRiskScore = summary.maximumRiskScore
		self.maximumRiskScoreFullRange = (summary.metadata?["maximumRiskScoreFullRange"] as? NSNumber)?.intValue ?? 0
		if let attenuationDurations = summary.metadata?["attenuationDurations"] as? [NSNumber] {
			self.configuredAttenuationDurations = attenuationDurations.map { Double($0.floatValue) }
		} else {
			self.configuredAttenuationDurations = []
		}
	}

	var description: String {
		var str = ""
		str.append("daysSinceLastExposure: \(daysSinceLastExposure)\n")
		str.append("matchedKeyCount: \(matchedKeyCount)\n")
		str.append("maximumRiskScore: \(maximumRiskScore)\n")
		str.append("maximumRiskScoreFullRange: \(maximumRiskScoreFullRange)\n")
		return str
	}
}
