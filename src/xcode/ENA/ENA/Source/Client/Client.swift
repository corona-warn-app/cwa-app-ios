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
	typealias KeySubmissionResponse = (Result<Void, Error>) -> Void
	typealias AvailableDaysCompletionHandler = (Result<[String], Failure>) -> Void
	typealias AvailableHoursCompletionHandler = (Result<[Int], Failure>) -> Void
	typealias RegistrationHandler = (Result<String, Failure>) -> Void
	typealias TestResultHandler = (Result<Int, Failure>) -> Void
	typealias TANHandler = (Result<String, Failure>) -> Void
	typealias DayCompletionHandler = (Result<SAPDownloadedPackage, Failure>) -> Void
	typealias HourCompletionHandler = (Result<SAPDownloadedPackage, Failure>) -> Void
	typealias AppConfigurationCompletion = (SAP_ApplicationConfiguration?) -> Void
	typealias CountryFetchCompletion = (Result<[Country], Failure>) -> Void

	// MARK: Interacting with a Client

	/// Gets the app configuration
	func appConfiguration(completion: @escaping AppConfigurationCompletion)

	#if INTEROP

	/// Determines days that can be downloaded.
	///
	/// - Parameters:
	///   - country: Country code
	///   - completion: completion callback which includes the list of available days
	func availableDays(
		forCountry country: String,
		completion: @escaping AvailableDaysCompletionHandler
	)

	/// Determines hours that can be downloaded for a given day.
	func availableHours(
		day: String,
		country: String,
		completion: @escaping AvailableHoursCompletionHandler
	)

	/// Fetches the keys for a given day and country code
	/// - Parameters:
	///   - day: The day that the keys belong to
	///   - country: It should be country code, like DE stands for Germany
	///   - completion: Once the request is done, the completion is called.
	func fetchDay(
		_ day: String,
		forCountry country: String,
		completion: @escaping DayCompletionHandler
	)

	/// Fetches the keys for a given `hour` of a specific `day`.
	func fetchHour(
		_ hour: Int,
		day: String,
		country: String,
		completion: @escaping HourCompletionHandler
	)

	#else

	/// Determines days that can be downloaded.
	func availableDays(completion: @escaping AvailableDaysCompletionHandler)

	/// Determines hours that can be downloaded for a given day.
	func availableHours(
		day: String,
		completion: @escaping AvailableHoursCompletionHandler
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

	#endif

	// MARK: Getting the Configuration

	typealias ExposureConfigurationCompletionHandler = (ENExposureConfiguration?) -> Void

	/// Gets the remove exposure configuration. See `ENExposureConfiguration` for more details
	/// Parameters:
	/// - completion: Will be called with the remove configuration or an error if something went wrong. The completion handler will always be called on the main thread.
	func exposureConfiguration(
		completion: @escaping ExposureConfigurationCompletionHandler
	)

	/// Gets the list of available countries for key submission.
	func supportedCountries(completion: @escaping CountryFetchCompletion)
	
	/// Gets the registration token
	func getRegistrationToken(
		forKey key: String,
		withType type: String,
		isFake: Bool,
		completion completeWith: @escaping RegistrationHandler
	)

	// getTestResultForDevice
	func getTestResult(
		forDevice registrationToken: String,
		isFake: Bool,
		completion completeWith: @escaping TestResultHandler
	)

	// getTANForDevice
	func getTANForExposureSubmit(
		forDevice registrationToken: String,
		isFake: Bool,
		completion completeWith: @escaping TANHandler
	)

	// MARK: Submit keys

	/// Submits exposure keys to the backend. This makes the local information available to the world so that the risk of others can be calculated on their local devices.
	/// - Parameters:
	///   - payload: A set of properties to provide during the submission process
	///   - isFake: flag to indicate a fake request
	///   - completion: the completion handler of the submission call
	func submit(
		payload: CountrySubmissionPayload,
		isFake: Bool,
		completion: @escaping KeySubmissionResponse
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
			return "\(AppStrings.ExposureSubmissionError.other)\(code)\(AppStrings.ExposureSubmissionError.otherend)"
		case .invalidPayloadOrHeaders:
			return "Received an invalid payload or headers."
		case .invalidTan:
			return AppStrings.ExposureSubmissionError.invalidTan
		case .requestCouldNotBeBuilt:
			return "The submission request could not be built correctly."
		case let .simpleError(errorString):
			return errorString
		case let .other(error):
			return error.localizedDescription
		}
	}
}

/// Combined model for a submit keys request
struct CountrySubmissionPayload {

	/// The exposure keys to submit
	let exposureKeys: [ENTemporaryExposureKey]

	/// whether or not the consent was given to share the keys with the european federal gateway server
	let consentToFederation: Bool

	/// the list of countries to check for any exposures
	let visitedCountries: [Country]

	/// a transaction number
	let tan: String
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

	#if INTEROP
	/// Fetch the keys with the given days and country code
	func fetchDays(
			_ days: [String],
			forCountry country: String,
			completion completeWith: @escaping (DaysResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [String: SAPDownloadedPackage]()

		let group = DispatchGroup()
		for day in days {
			group.enter()

			fetchDay(day, forCountry: country) { result in
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

	func fetchDays(
		_ days: [String],
		hours: [Int],
		of day: String,
		country: String,
		completion completeWith: @escaping DaysAndHoursCompletionHandler
	) {
		let group = DispatchGroup()
		var hoursResult = HoursResult(errors: [], bucketsByHour: [:], day: day)
		var daysResult = DaysResult(errors: [], bucketsByDay: [:])

		group.enter()
		fetchDays(days, forCountry: country) { result in
			daysResult = result
			group.leave()
		}

		group.enter()
		fetchHours(hours, day: day, country: country) { result in
			hoursResult = result
			group.leave()
		}
		group.notify(queue: .main) {
			completeWith(FetchedDaysAndHours(hours: hoursResult, days: daysResult))
		}
	}

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping FetchHoursCompletionHandler
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: SAPDownloadedPackage]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			self.fetchHour(hour, day: day, country: country) { result in
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

	#else

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

	#endif

	typealias DaysAndHoursCompletionHandler = (FetchedDaysAndHours) -> Void
}
