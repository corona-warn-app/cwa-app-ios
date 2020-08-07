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

protocol ExposureSubmissionService: class {
	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void
	typealias RegistrationHandler = (Result<String, ExposureSubmissionError>) -> Void
	typealias TestResultHandler = (Result<TestResult, ExposureSubmissionError>) -> Void
	typealias TANHandler = (Result<String, ExposureSubmissionError>) -> Void

	func submitExposure(completionHandler: @escaping ExposureSubmissionHandler)
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	)
	func getTestResult(_ completeWith: @escaping TestResultHandler)
	func hasRegistrationToken() -> Bool
	func deleteTest()
	var devicePairingConsentAcceptTimestamp: Int64? { get }
	var devicePairingSuccessfulTimestamp: Int64? { get }
	func preconditions() -> ExposureManagerState
	func acceptPairing()
	func fakeRequest(completionHandler: ExposureSubmissionHandler?)
}
