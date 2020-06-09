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

final class ClientMock {
	// MARK: Creating a Mock Client
	init(submissionError: SubmissionError?) {
		self.submissionError = submissionError
	}

	// MARK: Properties
	let submissionError: SubmissionError?
	var onAppConfiguration: (AppConfigurationCompletion) -> Void = { $0(nil) }
}

extension ClientMock: Client {
	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		onAppConfiguration(completion)
	}

	func availableDays(completion: @escaping AvailableDaysCompletionHandler) {
		completion(.success([]))
	}

	func availableHours(day: String, completion: @escaping AvailableHoursCompletionHandler) {
		completion(.success([]))
	}

	func fetchDay(_: String, completion: @escaping DayCompletionHandler) {}

	func fetchHour(_: Int, day: String, completion: @escaping HourCompletionHandler) {}

	func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
		completion(ENExposureConfiguration())
	}

	func submit(keys _: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
		completion(submissionError)
	}

	func getRegistrationToken(forKey _: String, withType: String, completion completeWith: @escaping RegistrationHandler) {
		completeWith(.success("dummyRegistrationToken"))
	}

	func getTestResult(forDevice device: String, completion completeWith: @escaping TestResultHandler) {
		completeWith(.success(2))
	}

	func getTANForExposureSubmit(forDevice device: String, completion completeWith: @escaping TANHandler) {
		completeWith(.success("dummyTan"))
	}

	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		completion(SAP_ApplicationConfiguration())
	}
}
