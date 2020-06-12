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

	var previousRiskLevel: EitherLowOrIncreasedRiskLevel? { get set }

	func clearAll(key: String?)
}
