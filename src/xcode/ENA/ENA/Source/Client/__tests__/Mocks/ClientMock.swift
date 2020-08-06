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
	
	// MARK: - Creating a Mock Client.

	/// Creates a mock `Client` implementation.
	///
	/// - parameters:
	///		- availableDaysAndHours: return this value when the `availableDays(_:)` or `availableHours(_:)` is called, or an error if `urlRequestFailure` is passed.
	///		- downloadedPackage: return this value when `fetchDay(_:)` or `fetchHour(_:)` is called, or an error if `urlRequestFailure` is passed.
	///		- submissionError: when set, `submit(_:)` will fail with this error.
	///		- urlRequestFailure: when set, calls (see above) will fail with this error
	init(
		availableDaysAndHours: DaysAndHours = DaysAndHours(days: [], hours: []),
		downloadedPackage: SAPDownloadedPackage? = nil,
		submissionError: SubmissionError? = nil,
		urlRequestFailure: Client.Failure? = nil
	) {
		self.availableDaysAndHours = availableDaysAndHours
		self.downloadedPackage = downloadedPackage
		self.submissionError = submissionError
		self.urlRequestFailure = urlRequestFailure
	}

	// MARK: - Properties.
	
	let submissionError: SubmissionError?
	let urlRequestFailure: Client.Failure?
	let availableDaysAndHours: DaysAndHours
	let downloadedPackage: SAPDownloadedPackage?

	// MARK: - Configurable Mock Callbacks.

	var onAppConfiguration: (AppConfigurationCompletion) -> Void = { $0(nil) }
	var onGetTestResult: ((String, Bool, TestResultHandler) -> Void)?
	var onSubmit: (([ENTemporaryExposureKey], String, Bool, @escaping SubmitKeysCompletionHandler) -> Void)?
	var onGetRegistrationToken: ((String, String, Bool, @escaping RegistrationHandler) -> Void)?
	var onGetTANForExposureSubmit: ((String, Bool, @escaping TANHandler) -> Void)?
}

extension ClientMock: Client {
	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		onAppConfiguration(completion)
	}

	func availableDays(completion: @escaping AvailableDaysCompletionHandler) {
		if let failure = urlRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(availableDaysAndHours.days))
	}

	func availableHours(day: String, completion: @escaping AvailableHoursCompletionHandler) {
		if let failure = urlRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(availableDaysAndHours.hours))
	}

	func fetchDay(_: String, completion: @escaping DayCompletionHandler) {
		if let failure = urlRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(downloadedPackage ?? SAPDownloadedPackage(keysBin: Data(), signature: Data())))
	}

	func fetchHour(_: Int, day: String, completion: @escaping HourCompletionHandler) {
		if let failure = urlRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(downloadedPackage ?? SAPDownloadedPackage(keysBin: Data(), signature: Data())))
	}

	func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
		completion(ENExposureConfiguration())
	}

	func submit(keys: [ENTemporaryExposureKey], tan: String, isFake: Bool, completion: @escaping SubmitKeysCompletionHandler) {
		guard let onSubmit = self.onSubmit else {
			completion(submissionError)
			return
		}

		onSubmit(keys, tan, isFake, completion)
	}

	func getRegistrationToken(forKey: String, withType: String, isFake: Bool, completion completeWith: @escaping RegistrationHandler) {
		guard let onGetRegistrationToken = self.onGetRegistrationToken else {
			completeWith(.success("dummyRegistrationToken"))
			return
		}

		onGetRegistrationToken(forKey, withType, isFake, completeWith)
	}

	func getTestResult(forDevice device: String, isFake: Bool, completion completeWith: @escaping TestResultHandler) {
		guard let onGetTestResult = self.onGetTestResult else {
			completeWith(.success(TestResult.positive.rawValue))
			return
		}

		onGetTestResult(device, isFake, completeWith)
	}

	func getTANForExposureSubmit(forDevice device: String, isFake: Bool, completion completeWith: @escaping TANHandler) {
		guard let onGetTANForExposureSubmit = self.onGetTANForExposureSubmit else {
			completeWith(.success("dummyTan"))
			return
		}

		onGetTANForExposureSubmit(device, isFake, completeWith)
	}
}
