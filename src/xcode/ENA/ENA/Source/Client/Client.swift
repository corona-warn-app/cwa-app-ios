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

import ExposureNotification
import Foundation

/// Describes how to interfact with the backend.
protocol Client {
	// MARK: Types

	typealias Failure = URLSession.Response.Failure
	typealias SubmitKeysCompletionHandler = (SubmissionError?) -> Void
	typealias AvailableDaysCompletionHandler = (Result<[String], Failure>) -> Void
	typealias AvailableHoursCompletionHandler = (Result<[Int], Failure>) -> Void
	typealias RegistrationHandler = (Result<String, Failure>) -> Void
	typealias TestResultHandler = (Result<Int, Failure>) -> Void
	typealias TANHandler = (Result<String, Failure>) -> Void
	typealias DayCompletionHandler = (Result<SAPDownloadedPackage, Failure>) -> Void
	typealias HourCompletionHandler = (Result<SAPDownloadedPackage, Failure>) -> Void

	// MARK: Interacting with a Client

	/// Determines days that can be downloaded.
	func availableDays(
		completion: @escaping AvailableDaysCompletionHandler
	)

	/// Determines hours that can be downloaded for a given day.
	func availableHours(
		day: String,
		completion: @escaping AvailableHoursCompletionHandler
	)

	// registersTheDevice
	func getRegistrationToken(
		forKey key: String,
		withType type: String, completion completeWith: @escaping RegistrationHandler
	)

	// getTestResultForDevice
	func getTestResult(
		forDevice registrationToken: String,
		completion completeWith: @escaping TestResultHandler
	)

	// getTANForDevice
	func getTANForExposureSubmit(
		forDevice registrationToken: String,
		completion completeWith: @escaping TANHandler
	)

	/// Fetches the keys for a given `day`.
	func fetchDay(
		_ day: String,
		completion: @escaping DayCompletionHandler
	)

	/// Fetches the keys for a given `hour` of a specific `day`.
	func fetchHour(
		_ hour: Int,
		day: String,
		completion: @escaping HourCompletionHandler
	)

	// MARK: Getting the Configuration

	typealias ExposureConfigurationCompletionHandler = (ENExposureConfiguration?) -> Void

	/// Gets the remove exposure configuration. See `ENExposureConfiguration` for more details
	/// Parameters:
	/// - completion: Will be called with the remove configuration or an error if something went wrong. The completion handler will always be called on the main thread.
	func exposureConfiguration(
		completion: @escaping ExposureConfigurationCompletionHandler
	)

	/// Submits exposure keys to the backend. This makes the local information available to the world so that the risk of others can be calculated on their local devices.
	/// Parameters:
	/// - keys: An array of `ENTemporaryExposureKey`s  to submit to the backend.
	/// - tan: A transaction number
	func submit(
		keys: [ENTemporaryExposureKey],
		tan: String,
		completion: @escaping SubmitKeysCompletionHandler
	)
}

enum SubmissionError: Error {
	case other(Error)
	case invalidPayloadOrHeaders
	case invalidTan
	case serverError(Int)
	case requestCouldNotBeBuilt
	case simpleError(String)
}

extension SubmissionError: LocalizedError {
	var localizedDescription: String {
		switch self {
		case let .serverError(code):
			return HTTPURLResponse.localizedString(forStatusCode: code)
		case .invalidPayloadOrHeaders:
			return "Received an invalid Payload or headers."
		case .invalidTan:
			return "Received invalid TAN"
		case .requestCouldNotBeBuilt:
			return "The Submission Request could not be built correctly."
		case let .simpleError(errorString):
			return errorString
		case let .other(error):
			return error.localizedDescription
		}
	}
}

struct DaysResult {
	let errors: [Client.Failure]
	let bucketsByDay: [String: SAPDownloadedPackage]
}

struct HoursResult {
	let errors: [Client.Failure]
	let bucketsByHour: [Int: SAPDownloadedPackage]
	let day: String
}

struct FetchedDaysAndHours {
	let hours: HoursResult
	let days: DaysResult
	var allKeyPackages: [SAPDownloadedPackage] {
		Array(hours.bucketsByHour.values) + Array(days.bucketsByDay.values)
	}
}

extension Client {
	typealias FetchHoursCompletionHandler = (HoursResult) -> Void

	func fetchDays(
		_ days: [String],
		completion completeWith: @escaping (DaysResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [String: SAPDownloadedPackage]()

		let group = DispatchGroup()

		for day in days {
			group.enter()
			fetchDay(day) { result in
				switch result {
				case let .success(bucket):
					buckets[day] = bucket
				case let .failure(error):
					errors.append(error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completeWith(
				DaysResult(
					errors: errors,
					bucketsByDay: buckets
				)
			)
		}
	}

	func fetchHours(
		_ hours: [Int],
		day: String,
		completion completeWith: @escaping FetchHoursCompletionHandler
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: SAPDownloadedPackage]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			self.fetchHour(hour, day: day) { result in
				switch result {
				case let .success(hourBucket):
					buckets[hour] = hourBucket
				case let .failure(error):
					errors.append(error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completeWith(
				HoursResult(errors: errors, bucketsByHour: buckets, day: day)
			)
		}
	}

	typealias DaysAndHoursCompletionHandler = (FetchedDaysAndHours) -> Void

	func fetchDays(
		_ days: [String],
		hours: [Int],
		of day: String,
		completion completeWith: @escaping DaysAndHoursCompletionHandler
	) {
		let group = DispatchGroup()
		var hoursResult = HoursResult(errors: [], bucketsByHour: [:], day: day)
		var daysResult = DaysResult(errors: [], bucketsByDay: [:])

		group.enter()
		fetchDays(days) { result in
			daysResult = result
			group.leave()
		}

		group.enter()
		fetchHours(hours, day: day) { result in
			hoursResult = result
			group.leave()
		}
		group.notify(queue: .main) {
			completeWith(FetchedDaysAndHours(hours: hoursResult, days: daysResult))
		}
	}
}
