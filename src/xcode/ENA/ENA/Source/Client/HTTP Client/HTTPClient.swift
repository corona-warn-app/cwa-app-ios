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
import ZIPFoundation

final class HTTPClient: Client {
	// MARK: Creating
	init(
		configuration: Configuration,
		packageVerifier: @escaping SAPDownloadedPackage.Verification = SAPDownloadedPackage.Verifier().verify,
		session: URLSession = .coronaWarnSession()
	) {
		self.session = session
		self.configuration = configuration
		self.packageVerifier = packageVerifier
	}

	// MARK: Properties
	let configuration: Configuration
	private let session: URLSession
	private let packageVerifier: SAPDownloadedPackage.Verification

	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		session.GET(configuration.configurationURL) { [weak self] result in
			switch result {
			case let .success(response):
				guard let data = response.body else {
					completion(nil)
					return
				}
				guard response.hasAcceptableStatusCode else {
					completion(nil)
					return
				}

				guard let package = SAPDownloadedPackage(compressedData: data) else {
					logError(message: "Failed to create downloaded package for app config.")
					completion(nil)
					return
				}

				guard let self = self else { return }

				// Configuration File Signature must be checked by the application since it is not verified by the operating system
				guard self.packageVerifier(package) else {
					logError(message: "Failed to verify app config signature")
					completion(nil)
					return
				}
				completion(try? SAP_ApplicationConfiguration(serializedData: package.bin))
			case .failure:
				completion(nil)
			}
		}
	}

	func exposureConfiguration(
		completion: @escaping ExposureConfigurationCompletionHandler
	) {
		log(message: "Fetching exposureConfiguation from: \(configuration.configurationURL)")
		appConfiguration { config in
			guard let config = config else {
				completion(nil)
				return
			}
			guard config.hasExposureConfig else {
				completion(nil)
				return
			}
			completion(try? ENExposureConfiguration(from: config.exposureConfig))
		}
	}

	func submit(
		keys: [ENTemporaryExposureKey],
		tan: String,
		isFake: Bool = false,
		completion: @escaping SubmitKeysCompletionHandler
	) {
		guard let request = try? URLRequest.submitKeysRequest(
			configuration: configuration,
			tan: tan,
			keys: keys,
			headerValue: isFake ? 1 : 0
		) else {
			completion(.requestCouldNotBeBuilt)
			return
		}

		session.response(for: request, isFake: isFake) { result in
            #if !RELEASE
            UserDefaults.standard.dmLastSubmissionRequest = request.httpBody
            #endif

			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200: completion(nil)
				case 201: completion(nil)
				case 400: completion(.invalidPayloadOrHeaders)
				case 403: completion(.invalidTan)
				default: completion(.serverError(response.statusCode))
				}
			case let .failure(error):
				completion(.other(error))
			}
		}
	}

	func availableDays(
		completion completeWith: @escaping AvailableDaysCompletionHandler
	) {
		let url = configuration.availableDaysURL

		session.GET(url) { result in
			switch result {
			case let .success(response):
				guard let data = response.body else {
					completeWith(.failure(.invalidResponse))
					return
				}
				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.invalidResponse))
					return
				}
				do {
					let decoder = JSONDecoder()
					let days = try decoder
						.decode(
							[String].self,
							from: data
						)
					completeWith(.success(days))
				} catch {
					completeWith(.failure(.invalidResponse))
					return
				}
			case let .failure(error):
				completeWith(.failure(error))
			}
		}
	}

	func availableHours(
		day: String,
		completion completeWith: @escaping AvailableHoursCompletionHandler
	) {
		let url = configuration.availableHoursURL(day: day)

		session.GET(url) { result in
			switch result {
			case let .success(response):
				// We accept 404 responses since this can happen in case there
				// have not been any new cases reported on that day.
				// We don't report this as an error to simplify things for the consumer.
				guard response.statusCode != 404 else {
					completeWith(.success([]))
					return
				}

				guard let data = response.body else {
					completeWith(.failure(.invalidResponse))
					return
				}

				do {
					let decoder = JSONDecoder()
					let hours = try decoder.decode([Int].self, from: data)
					completeWith(.success(hours))
				} catch {
					completeWith(.failure(.invalidResponse))
					return
				}
			case let .failure(error):
				completeWith(.failure(error))
			}
		}
	}

	func getTestResult(forDevice registrationToken: String, isFake: Bool = false, completion completeWith: @escaping TestResultHandler) {

		guard
			let testResultRequest = try? URLRequest.getTestResultRequest(
				configuration: configuration,
				registrationToken: registrationToken,
				headerValue: isFake ? 1 : 0
			) else {
				completeWith(.failure(.invalidResponse))
				return
		}

		session.response(for: testResultRequest, isFake: isFake) { result in
			switch result {
			case let .success(response):
				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.serverError(response.statusCode)))
					return
				}
				guard let testResultResponseData = response.body else {
					completeWith(.failure(.invalidResponse))
					logError(message: "Failed to register Device with invalid response")
					return
				}
				do {
					let response = try JSONDecoder().decode(
						FetchTestResultResponse.self,
						from: testResultResponseData
					)
					guard let testResult = response.testResult else {
						logError(message: "Failed to get test result with invalid response payload structure")
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(testResult))
				} catch {
					logError(message: "Failed to get test result with invalid response payload structure")
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				logError(message: "Failed to get test result due to error: \(error).")
			}
		}
	}

	func getTANForExposureSubmit(forDevice registrationToken: String, isFake: Bool = false, completion completeWith: @escaping TANHandler) {

		guard
			let tanForExposureSubmitRequest = try? URLRequest.getTanForExposureSubmitRequest(
				configuration: configuration,
				registrationToken: registrationToken,
				headerValue: isFake ? 1 : 0
			) else {
				completeWith(.failure(.invalidResponse))
				return
		}

		session.response(for: tanForExposureSubmitRequest, isFake: isFake) { result in
			switch result {
			case let .success(response):

				if response.statusCode == 400 {
					completeWith(.failure(.regTokenNotExist))
					return
				}
				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.serverError(response.statusCode)))
					return
				}
				guard let tanResponseData = response.body else {
					completeWith(.failure(.invalidResponse))
					logError(message: "Failed to get TAN")
					logError(message: String(response.statusCode))
					return
				}
				do {
					let response = try JSONDecoder().decode(
						GetTANForExposureSubmitResponse.self,
						from: tanResponseData
					)
					guard let tan = response.tan else {
						logError(message: "Failed to get TAN because of invalid response payload structure")
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(tan))
				} catch _ {
					logError(message: "Failed to get TAN because of invalid response payload structure")
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				logError(message: "Failed to get TAN due to error: \(error).")
			}
		}
	}

	func getRegistrationToken(forKey key: String, withType type: String, isFake: Bool = false, completion completeWith: @escaping RegistrationHandler) {

		guard
			let registrationTokenRequest = try? URLRequest.getRegistrationTokenRequest(
				configuration: configuration,
				key: key,
				type: type,
				headerValue: isFake ? 1 : 0
			) else {
				completeWith(.failure(.invalidResponse))
				return
		}

		session.response(for: registrationTokenRequest, isFake: isFake) { result in
			switch result {
			case let .success(response):
				if response.statusCode == 400 {
					if type == "TELETAN" {
						completeWith(.failure(.teleTanAlreadyUsed))
					} else {
						completeWith(.failure(.qRAlreadyUsed))
					}
					return
				}
				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.serverError(response.statusCode)))
					return
				}
				guard let registerResponseData = response.body else {
					completeWith(.failure(.invalidResponse))
					logError(message: "Failed to register Device with invalid response")
					return
				}

				do {
					let response = try JSONDecoder().decode(
						GetRegistrationTokenResponse.self,
						from: registerResponseData
					)
					guard let registrationToken = response.registrationToken else {
						logError(message: "Failed to register Device with invalid response payload structure")
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(registrationToken))
				} catch _ {
					logError(message: "Failed to register Device with invalid response payload structure")
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				logError(message: "Failed to registerDevices due to error: \(error).")
			}
		}
	}

	func fetchDay(
		_ day: String,
		completion completeWith: @escaping DayCompletionHandler
	) {
		let url = configuration.diagnosisKeysURL(day: day)

		session.GET(url) { result in
			switch result {
			case let .success(response):
				guard let dayData = response.body else {
					completeWith(.failure(.invalidResponse))
					logError(message: "Failed to download day '\(day)': invalid response")
					return
				}
				guard let package = SAPDownloadedPackage(compressedData: dayData) else {
					logError(message: "Failed to create signed package.")
					completeWith(.failure(.invalidResponse))
					return
				}
				completeWith(.success(package))
			case let .failure(error):
				completeWith(.failure(error))
				logError(message: "Failed to download day '\(day)' due to error: \(error).")
			}
		}
	}

	func fetchHour(
		_ hour: Int,
		day: String,
		completion completeWith: @escaping HourCompletionHandler
	) {
		let url = configuration.diagnosisKeysURL(day: day, hour: hour)
		session.GET(url) { result in
			switch result {
			case let .success(response):
				guard let hourData = response.body else {
					completeWith(.failure(.invalidResponse))
					return
				}
				log(message: "got hour: \(hourData.count)")
				guard let package = SAPDownloadedPackage(compressedData: hourData) else {
					logError(message: "Failed to create signed package.")
					completeWith(.failure(.invalidResponse))
					return
				}
				completeWith(.success(package))
			case let .failure(error):
				completeWith(.failure(error))
				logError(message: "failed to get day: \(error)")
			}
		}
	}
}

// MARK: Extensions

private extension HTTPClient {
	struct FetchTestResultResponse: Codable {
		let testResult: Int?
	}

	struct GetRegistrationTokenResponse: Codable {
		let registrationToken: String?
	}

	struct GetTANForExposureSubmitResponse: Codable {
		let tan: String?
	}
}

private extension URLRequest {
	static func submitKeysRequest(
		configuration: HTTPClient.Configuration,
		tan: String,
		keys: [ENTemporaryExposureKey],
		headerValue: Int
	) throws -> URLRequest {
		let payload = SAP_SubmissionPayload.with {
			$0.padding = self.getSubmissionPadding(for: keys)
			$0.keys = keys.compactMap { $0.sapKey }
		}
		let payloadData = try payload.serializedData()
		let url = configuration.submissionURL

		var request = URLRequest(url: url)

		request.setValue(
			tan,
			// TAN code associated with this diagnosis key submission.
			forHTTPHeaderField: "cwa-authorization"
		)

		request.setValue(
			"\(headerValue)",
			// Requests with a value of "0" will be fully processed.
			// Any other value indicates that this request shall be
			// handled as a fake request." ,
			forHTTPHeaderField: "cwa-fake"
		)

		// Add header padding for the GUID, in case it is
		// a fake request, otherwise leave empty.
		request.setValue(
			headerValue == 0 ? "" : String.getRandomString(of: 36),
			forHTTPHeaderField: "cwa-header-padding"
		)

		request.setValue(
			"application/x-protobuf",
			forHTTPHeaderField: "Content-Type"
		)

		request.httpMethod = "POST"
		request.httpBody = payloadData

		return request
	}

	static func getTestResultRequest(
		configuration: HTTPClient.Configuration,
		registrationToken: String,
		headerValue: Int
	) throws -> URLRequest {

		var request = URLRequest(url: configuration.testResultURL)

		request.setValue(
			"\(headerValue)",
			// Requests with a value of "0" will be fully processed.
			// Any other value indicates that this request shall be
			// handled as a fake request." ,
			forHTTPHeaderField: "cwa-fake"
		)

		// Add header padding.
		request.setValue(
			String.getRandomString(of: 7),
			forHTTPHeaderField: "cwa-header-padding"
		)

		request.setValue(
			"application/json",
			forHTTPHeaderField: "Content-Type"
		)

		request.httpMethod = "POST"

		// Add body padding to request.
		let originalBody = ["registrationToken": registrationToken]
		let paddedData = try getPaddedRequestBody(for: originalBody)
		request.httpBody = paddedData

		return request
	}

	static func getTanForExposureSubmitRequest(
		configuration: HTTPClient.Configuration,
		registrationToken: String,
		headerValue: Int
	) throws -> URLRequest {

		var request = URLRequest(url: configuration.tanRetrievalURL)

		request.setValue(
			"\(headerValue)",
			// Requests with a value of "0" will be fully processed.
			// Any other value indicates that this request shall be
			// handled as a fake request." ,
			forHTTPHeaderField: "cwa-fake"
		)

		// Add header padding.
		request.setValue(
			String.getRandomString(of: 14),
			forHTTPHeaderField: "cwa-header-padding"
		)

		request.setValue(
			"application/json",
			forHTTPHeaderField: "Content-Type"
		)

		request.httpMethod = "POST"

		// Add body padding to request.
		let originalBody = ["registrationToken": registrationToken]
		let paddedData = try getPaddedRequestBody(for: originalBody)
		request.httpBody = paddedData

		return request
	}

	static func getRegistrationTokenRequest(
		configuration: HTTPClient.Configuration,
		key: String,
		type: String,
		headerValue: Int
	) throws -> URLRequest {

		var request = URLRequest(url: configuration.registrationURL)

		request.setValue(
			"\(headerValue)",
			// Requests with a value of "0" will be fully processed.
			// Any other value indicates that this request shall be
			// handled as a fake request." ,
			forHTTPHeaderField: "cwa-fake"
		)

		// Add header padding.
		request.setValue(
			"",
			forHTTPHeaderField: "cwa-header-padding"
		)

		request.setValue(
			"application/json",
			forHTTPHeaderField: "Content-Type"
		)

		request.httpMethod = "POST"

		// Add body padding to request.
		let originalBody = ["key": key, "keyType": type]
		let paddedData = try getPaddedRequestBody(for: originalBody)
		request.httpBody = paddedData

		return request
	}

	// MARK: - Helper methods for adding padding to the requests.

	/// This method recreates the request body with a padding that consists of a random string.
	/// The entire request body must not be bigger than `maxRequestPayloadSize`.
	/// Note that this method is _not_ used for the key submission step, as this needs a different handling.
	/// Please check `getSubmissionPadding()` for this case.
	private static func getPaddedRequestBody(for originalBody: [String: String]) throws -> Data {
		// This is the maximum size of bytes the request body should have.
		let maxRequestPayloadSize = 250

		// Copying in order to not use inout parameters.
		var paddedBody = originalBody
		paddedBody["requestPadding"] = ""
		let paddedData = try JSONEncoder().encode(paddedBody)
		let paddingSize = maxRequestPayloadSize - paddedData.count
		let padding = String.getRandomString(of: paddingSize)
		paddedBody["requestPadding"] = padding
		return try JSONEncoder().encode(paddedBody)
	}

	/// This method recreates the request body of the submit keys request with a padding that fills up to resemble
	/// a request with 14 +`n` keys. Note that the `n`parameter is currently set to 0, but can change in the future
	/// when there will be support for 15 keys.
	private static func getSubmissionPadding(for keys: [ENTemporaryExposureKey]) -> Data {
		// This parameter denotes how many keys 14 + n have to be padded.
		let n = 0
		let paddedKeysAmount = 14 + n - keys.count
		guard paddedKeysAmount > 0 else { return Data() }
		guard let data = (String.getRandomString(of: 28 * paddedKeysAmount)).data(using: .ascii) else { return Data() }
		return data
	}
}

private extension ENExposureConfiguration {
	convenience init(from riskscoreParameters: SAP_RiskScoreParameters) throws {
		self.init()
		// We are intentionally not setting minimumRiskScore.
		attenuationLevelValues = riskscoreParameters.attenuation.asArray
		daysSinceLastExposureLevelValues = riskscoreParameters.daysSinceLastExposure.asArray
		durationLevelValues = riskscoreParameters.duration.asArray
		transmissionRiskLevelValues = riskscoreParameters.transmission.asArray
	}
}

private extension SAP_RiskLevel {
	var asNumber: NSNumber {
		NSNumber(value: rawValue)
	}
}

private extension SAP_RiskScoreParameters.TransmissionRiskParameter {
	var asArray: [NSNumber] {
		[appDefined1, appDefined2, appDefined3, appDefined4, appDefined5, appDefined6, appDefined7, appDefined8].map { $0.asNumber }
	}
}

private extension SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameter {
	var asArray: [NSNumber] {
		[ge14Days, ge12Lt14Days, ge10Lt12Days, ge8Lt10Days, ge6Lt8Days, ge4Lt6Days, ge2Lt4Days, ge0Lt2Days].map { $0.asNumber }
	}
}

private extension SAP_RiskScoreParameters.DurationRiskParameter {
	var asArray: [NSNumber] {
		[eq0Min, gt0Le5Min, gt5Le10Min, gt10Le15Min, gt15Le20Min, gt20Le25Min, gt25Le30Min, gt30Min].map { $0.asNumber }
	}
}

private extension SAP_RiskScoreParameters.AttenuationRiskParameter {
	var asArray: [NSNumber] {
		[gt73Dbm, gt63Le73Dbm, gt51Le63Dbm, gt33Le51Dbm, gt27Le33Dbm, gt15Le27Dbm, gt10Le15Dbm, le10Dbm].map { $0.asNumber }
	}
}
