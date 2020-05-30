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
import ExposureNotification

class MockTestClient: Client {
	func availableDays(completion: @escaping AvailableDaysCompletionHandler) {
		completion(.success([]))
	}

	func availableHours(day _: String, completion: @escaping AvailableHoursCompletionHandler) {
		completion(.success([]))
	}

	func fetchDay(_: String, completion _: @escaping DayCompletionHandler) {}

	func fetchHour(_: Int, day _: String, completion _: @escaping HourCompletionHandler) {}

	let submissionError: SubmissionError?

	init(submissionError: SubmissionError?) {
		self.submissionError = submissionError
	}

	func exposureConfiguration(completion _: @escaping ExposureConfigurationCompletionHandler) {}

	func submit(keys _: [ENTemporaryExposureKey], tan _: String, completion: @escaping SubmitKeysCompletionHandler) {
		completion(submissionError)
	}

	func getRegistrationToken(forKey _: String, withType _: String, completion completeWith: @escaping RegistrationHandler) {
		completeWith(.success("dummyRegistrationToken"))
	}

	func getTestResult(forDevice _: String, completion completeWith: @escaping TestResultHandler) {
		completeWith(.success(2))
	}

	func getTANForExposureSubmit(forDevice _: String, completion completeWith: @escaping TANHandler) {
		completeWith(.success("dummyTan"))
	}
}
