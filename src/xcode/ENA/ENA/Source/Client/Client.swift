//
// 🦠 Corona-Warn-App
//

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
	typealias DayCompletionHandler = (Result<PackageDownloadResponse, Failure>) -> Void
	typealias HourCompletionHandler = (Result<PackageDownloadResponse, Failure>) -> Void
	typealias CountryFetchCompletion = (Result<[Country], Failure>) -> Void
	typealias OTPAuthorizationCompletionHandler = (Result<Date, OTPError>) -> Void
	typealias PPAnalyticsSubmitionCompletionHandler = (Result<Void, PPASError>) -> Void
	typealias TraceWarningPackageDiscoveryCompletionHandler = (Result<TraceWarningDiscovery, TraceWarningError>) -> Void
	typealias TraceWarningPackageDownloadCompletionHandler = (Result<PackageDownloadResponse, TraceWarningError>) -> Void
	
	// MARK: Interacting with a Client

	/// Determines days that can be downloaded.
	///
	/// - Parameters:
	///   - country: Country code
	///   - completion: completion callback which includes the list of available days
	func availableDays(
		forCountry country: String,
		completion: @escaping AvailableDaysCompletionHandler
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

	// MARK: Getting the Configuration

	/// Gets the registration token
	func getRegistrationToken(
		forKey key: String,
		withType type: String,
		isFake: Bool,
		completion completeWith: @escaping RegistrationHandler
	)

	/// Gets the test result for the device
	func getTestResult(
		forDevice registrationToken: String,
		isFake: Bool,
		completion completeWith: @escaping TestResultHandler
	)

	/// Gets the TAN for the device
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

	// MARK: OTP Authorization

	/// Authorizes an otp at our servers with a tuple of device token and api token as authentication and the otp as payload.
	/// - Parameters:
	///   - otp: the otp to authorize
	///   - ppacToken: the ppac token which is generated previously by the PPACService
	///   - isFake: Flag to indicate a fake request
	///   - forceApiTokenHeader: A Flag that indicates, if a special header flag is send to enforce to accept the API Token. ONLY executable for non release builds
	///   - completion: The completion handler of the submission call, which contains the expirationDate of the otp as String
	func authorize(
		otp: String,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool,
		completion: @escaping OTPAuthorizationCompletionHandler
	)

	// MARK: PPA Submit

	/// Authorizes an otp at our servers with a tuple of device token and api token as authentication and the otp as payload.
	/// - Parameters:
	///   - payload: SAP_Internal_Ppdd_PPADataRequestIOS, which contains several metrics data
	///   - ppacToken: the ppac token which is generated previously by the PPACService
	///   - isFake: Flag to indicate a fake request
	///   - forceApiTokenHeader: A Flag that indicates, if a special header flag is send to enforce to accept the API Token. ONLY executable for non release builds
	///   - completion: The completion handler of the submission call, which contains the expirationDate of the otp as String
	func submit(
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool,
		completion: @escaping PPAnalyticsSubmitionCompletionHandler
	)
	
	// MARK: Event / Check-In (aka traceWarning)
	
	/// GET call to load the IDs from the traceWarnings from CDN. It eventually returns the ID of the the first and last TraceWarningPackage that is available on CDN. The return is the set of all integers between (and including) first and last.
	/// - Parameters:
	///   - country: The country.ID for which country we want the IDs.
	///   - completion: The completion handler of the get call, which contains the set of availbalePackagesOnCDN.
	func traceWarningPackageDiscovery(
		country: String,
		completion: @escaping TraceWarningPackageDiscoveryCompletionHandler
	)
	
	/// GET call to load the packge to the corresponding ID of a traceWarning from CDN. It returns the downloaded package. But it can also be empty. This is indicates by a specific http header field and is mapped into a property of the PackageDownloadResponse.
	/// - Parameters:
	///   - country: The country.ID for which country we want the IDs.
	///   - packageId: The packageID for the package we want to download
	///   - completion: The completion handler of the get call, which contains a PackageDownloadResponse
	func traceWarningPackageDownload(
		country: String,
		packageId: Int,
		completion: @escaping TraceWarningPackageDownloadCompletionHandler
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

// Do not edit this cases as they are decoded as they are from the server.
enum PPAServerErrorCode: String, Codable {
	case API_TOKEN_ALREADY_ISSUED
	case API_TOKEN_EXPIRED
	case API_TOKEN_QUOTA_EXCEEDED
	case DEVICE_BLOCKED
	case DEVICE_TOKEN_INVALID
	case DEVICE_TOKEN_REDEEMED
	case DEVICE_TOKEN_SYNTAX_ERROR
	case APK_CERTIFICATE_MISMATCH
	case APK_PACKAGE_NAME_MISMATCH
	case ATTESTATION_EXPIRED
	case JWS_SIGNATURE_VERIFICATION_FAILED
	case NONCE_MISMATCH
	case SALT_REDEEMED
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

/// A container for a downloaded `SAPDownloadedPackage` and its corresponding `ETag`, if given.
struct PackageDownloadResponse {
	let package: SAPDownloadedPackage?

	/// The response ETag
	///
	/// This is used to identify and revoke packages.
	let etag: String?
	
	var isEmpty: Bool {
		return package == nil
	}
}

/// Combined model for a submit keys request
struct CountrySubmissionPayload {

	/// The exposure keys to submit
	let exposureKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]

	/// the list of countries to check for any exposures
	let visitedCountries: [Country]

	/// a transaction number
	let tan: String
}

struct DaysResult {
	let errors: [Client.Failure]
	let bucketsByDay: [String: PackageDownloadResponse]
}

struct HoursResult {
	let errors: [Client.Failure]
	let bucketsByHour: [Int: PackageDownloadResponse]
	let day: String
}

struct FetchedDaysAndHours {
	let hours: HoursResult
	let days: DaysResult
	var allKeyPackages: [PackageDownloadResponse] {
		Array(hours.bucketsByHour.values) + Array(days.bucketsByDay.values)
	}
}

extension Client {
	typealias FetchDaysCompletionHandler = (DaysResult) -> Void
	typealias FetchHoursCompletionHandler = (HoursResult) -> Void

	/// Fetch the keys with the given days and country code
	func fetchDays(
			_ days: [String],
			forCountry country: String,
			completion completeWith: @escaping FetchDaysCompletionHandler
	) {
		var errors = [Client.Failure]()
		var buckets = [String: PackageDownloadResponse]()

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

}
