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

private func _withPrefix(_ name: String) -> Notification.Name {
	Notification.Name("com.sap.ena.\(name)")
}

extension Notification.Name {
	static let isOnboardedDidChange = _withPrefix("isOnboardedDidChange")
	static let dateLastExposureDetectionDidChange = _withPrefix("dateLastExposureDetectionDidChange")
	static let dateOfAcceptedPrivacyNoticeDidChange = _withPrefix("dateOfAcceptedPrivacyNoticeDidChange")
	static let developerSubmissionBaseURLOverrideDidChange = _withPrefix("developerSubmissionBaseURLOverride")
	static let developerDistributionBaseURLOverrideDidChange = _withPrefix("developerDistributionBaseURLOverride")
	static let developerVerificationBaseURLOverrideDidChange = _withPrefix("developerVerificationBaseURLOverride")

	static let allowRiskChangesNotificationDidChange = _withPrefix("allowRiskChangesNotificationDidChange")
	static let allowTestsStatusNotificationDidChange = _withPrefix("allowTestsStatusNotificationDidChange")

	// Temporary Notification until implemented by actual transaction flow
	static let didDetectExposureDetectionSummary = _withPrefix("didDetectExposureDetectionSummary")
	static let teleTanDidChange = _withPrefix("teleTanDidChange")
	static let tanDidChange = _withPrefix("tanDidChange")
	static let testGUIDDidChange = _withPrefix("testGUIDDidChange")
	static let devicePairingConsentAcceptDidChange = _withPrefix("devicePairingConsentAcceptDidChange")
	static let devicePairingConsentAcceptTimestampDidChange = _withPrefix("devicePairingConsentAcceptTimestampDidChange")
	static let devicePairingSuccessfulTimestampDidChange = _withPrefix("devicePairingSuccessfulTimestampDidChange")
	static let isAllowedToSubmitDiagnosisKeysDidChange = _withPrefix("isAllowedToSubmitDiagnosisKeysDidChange")
	static let registrationTokenDidChange = _withPrefix("registrationTokenDidChange")
	static let hasSeenSubmissionExposureTutorialDidChange = _withPrefix("hasSeenSubmissionExposureTutorialDidChange")
	static let lastSuccessfulSubmitDiagnosisKeyTimestampDidChange = _withPrefix("lastSuccessfulSubmitDiagnosisKeyTimestampDidChange")
	static let numberOfSuccesfulSubmissionsDidChange = _withPrefix("numberOfSuccesfulSubmissionsDidChange")
	static let initialSubmitCompletedDidChange = _withPrefix("initialSubmitCompletedDidChange")
	static let submitConsentAcceptTimestampDidChange = _withPrefix("submitConsentAcceptTimestampDidChange")
	static let submitConsentAcceptDidChange = _withPrefix("submitConsentAcceptDidChange")
	static let testResultReceivedTimeStampDidChange = _withPrefix("testResultReceivedTimeStampDidChange")
}
