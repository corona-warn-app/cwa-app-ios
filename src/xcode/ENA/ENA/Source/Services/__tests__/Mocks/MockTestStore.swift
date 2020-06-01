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

@testable import ENA
import Foundation

class MockTestStore: Store {
	var testResultReceivedTimeStamp: Int64?
	
	func clearAll() {}

	var hasSeenSubmissionExposureTutorial: Bool = false

	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?

	var numberOfSuccesfulSubmissions: Int64?

	var initialSubmitCompleted: Bool = false

	var submitConsentAcceptTimestamp: Int64?

	var submitConsentAccept: Bool = false

	var isOnboarded: Bool = false

	var dateLastExposureDetection: Date?

	var dateOfAcceptedPrivacyNotice: Date?

	var allowsCellularUse: Bool = false

	var developerSubmissionBaseURLOverride: String?

	var developerDistributionBaseURLOverride: String?

	var developerVerificationBaseURLOverride: String?

	var teleTan: String?

	var tan: String?

	var testGUID: String?

	var devicePairingConsentAccept: Bool = false

	var devicePairingConsentAcceptTimestamp: Int64?

	var devicePairingSuccessfulTimestamp: Int64?

	var isAllowedToSubmitDiagnosisKeys: Bool = false

	var registrationToken: String?

	var allowRiskChangesNotification: Bool = true

	var allowTestsStatusNotification: Bool = true
}
