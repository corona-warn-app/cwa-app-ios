//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import ZIPFoundation

// swiftlint:disable:next type_body_length
final class HTTPClient: Client {

	// MARK: - Init

	init(
		serverEnvironmentProvider: ServerEnvironmentProviding,
		packageVerifier: @escaping SAPDownloadedPackage.Verification = SAPDownloadedPackage.Verifier().verify,
		session: URLSession = .coronaWarnSession()
	) {
		self.serverEnvironmentProvider = serverEnvironmentProvider
		self.session = session
		self.packageVerifier = packageVerifier
	}

	// MARK: - Overrides

	// MARK: - Protocol Client

	func availableDays(
		forCountry country: String,
		completion completeWith: @escaping AvailableDaysCompletionHandler
	) {
		let url = configuration.availableDaysURL(forCountry: country)
		availableDays(from: url, completion: completeWith)
	}

	func fetchDay(
		_ day: String,
		forCountry country: String,
		completion completeWith: @escaping DayCompletionHandler
	) {
		let url = configuration.diagnosisKeysURL(day: day, forCountry: country)
		fetchDay(from: url, completion: completeWith)
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
						completeWith(.failure(.qrAlreadyUsed))
					}
					return
				}
				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.serverError(response.statusCode)))
					return
				}
				guard let registerResponseData = response.body else {
					completeWith(.failure(.invalidResponse))
					Log.error("Failed to register Device with invalid response", log: .api)
					return
				}

				do {
					let response = try JSONDecoder().decode(
						GetRegistrationTokenResponse.self,
						from: registerResponseData
					)
					guard let registrationToken = response.registrationToken else {
						Log.error("Failed to register Device with invalid response payload structure", log: .api)
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(registrationToken))
				} catch _ {
					Log.error("Failed to register Device with invalid response payload structure", log: .api)
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				Log.error("Failed to registerDevices due to error: \(error).", log: .api)
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
		Log.debug("Requesting TestResult", log: .api)
		session.response(for: testResultRequest, isFake: isFake) { result in
			Log.debug("Received TestResult", log: .api)
			switch result {
			case let .success(response):

				if response.statusCode == 400 {
					completeWith(.failure(.qrDoesNotExist))
					return
				}

				guard response.hasAcceptableStatusCode else {
					completeWith(.failure(.serverError(response.statusCode)))
					return
				}
				guard let testResultResponseData = response.body else {
					completeWith(.failure(.invalidResponse))
					Log.error("Failed to register Device with invalid response", log: .api)
					return
				}
				do {
					let response = try JSONDecoder().decode(
						FetchTestResultResponse.self,
						from: testResultResponseData
					)
					guard let testResult = response.testResult else {
						Log.error("Failed to get test result with invalid response payload structure", log: .api)
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(testResult))
				} catch {
					Log.error("Failed to get test result with invalid response payload structure", log: .api)
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				Log.error("Failed to get test result due to error: \(error).", log: .api)
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
					Log.error("Failed to get TAN", log: .api)
					Log.error(String(response.statusCode), log: .api)
					return
				}
				do {
					let response = try JSONDecoder().decode(
						GetTANForExposureSubmitResponse.self,
						from: tanResponseData
					)
					guard let tan = response.tan else {
						Log.error("Failed to get TAN because of invalid response payload structure", log: .api)
						completeWith(.failure(.invalidResponse))
						return
					}
					completeWith(.success(tan))
				} catch _ {
					Log.error("Failed to get TAN because of invalid response payload structure", log: .api)
					completeWith(.failure(.invalidResponse))
				}
			case let .failure(error):
				completeWith(.failure(error))
				Log.error("Failed to get TAN due to error: \(error).", log: .api)
			}
		}
	}

	func submit(payload: CountrySubmissionPayload, isFake: Bool, completion: @escaping KeySubmissionResponse) {
		guard let request = try? URLRequest.keySubmissionRequest(configuration: configuration, payload: payload, isFake: isFake) else {
			completion(.failure(SubmissionError.requestCouldNotBeBuilt))
			return
		}

		session.response(for: request, isFake: isFake) { result in
			#if !RELEASE
			UserDefaults.standard.dmLastSubmissionRequest = request.httpBody
			#endif

			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200..<300: completion(.success(()))
				case 400: completion(.failure(SubmissionError.invalidPayloadOrHeaders))
				case 403: completion(.failure(SubmissionError.invalidTan))
				default: completion(.failure(SubmissionError.serverError(response.statusCode)))
				}
			case let .failure(error):
				completion(.failure(SubmissionError.other(error)))
			}
		}
	}

	func authorize(
		otp: String,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool = false,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let request = try? URLRequest.authorizeOTPRequest(
				configuration: configuration,
				otp: otp,
				ppacToken: ppacToken,
				isFake: isFake,
				forceApiTokenHeader: forceApiTokenHeader) else {
			completion(.failure(.invalidResponseError))
			return
		}

		session.response(for: request, isFake: isFake, completion: { [weak self] result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					self?.otpAuthorizationSuccessHandler(for: response, completion: completion)
				case 400, 401, 403, 429:
					self?.otpAuthorizationFailureHandler(for: response, completion: completion)
				case 500:
					Log.error("Failed to get authorized OTP - 500 status code", log: .api)
					completion(.failure(.internalServerError))
				default:
					Log.error("Failed to authorize OTP - response error", log: .api)
					Log.error(String(response.statusCode), log: .api)
					completion(.failure(.internalServerError))
				}
			case let .failure(error):
				Log.error("Failed to authorize OTP due to error: \(error).", log: .api)
				completion(.failure(.invalidResponseError))
			}
		})
	}

	func submit(
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool = false,
		completion: @escaping PPAnalyticsSubmitionCompletionHandler
	) {
		guard let request = try? URLRequest.ppaSubmit(
				configuration: configuration,
				payload: payload,
				ppacToken: ppacToken,
				isFake: isFake,
				forceApiTokenHeader: forceApiTokenHeader) else {
			completion(.failure(.urlCreationError))
			return
		}

		session.response(for: request, isFake: isFake, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 204:
					completion(.success(()))
				case 400, 401, 403, 429:
					guard let responseBody = response.body else {
						Log.error("Error in response body: \(response.statusCode)", log: .api)
						completion(.failure(.responseError(response.statusCode)))
						return
					}
					do {
						let decodedResponse = try JSONDecoder().decode(
							PPACResponse.self,
							from: responseBody
						)
						guard let errorCode = decodedResponse.errorCode else {
							Log.error("Error at converting decodedResponse to PPACResponse", log: .api)
							completion(.failure(.jsonError))
							return
						}
						Log.error("Server error at submitting anatlytics data", log: .api)
						completion(.failure(.serverError(errorCode)))
					} catch {
						Log.error("Error at decoding server response json", log: .api, error: error)
						completion(.failure(.jsonError))
					}
				case 500:
					Log.error("Server error at submitting anatlytics data", log: .api)
					completion(.failure(.responseError(500)))
				default:
					Log.error("Error in response body: \(response.statusCode)", log: .api)
					completion(.failure(.responseError(response.statusCode)))
				}
			case let .failure(error):
				Log.error("Error in response body: \(error)", log: .api)
				completion(.failure(.serverFailure(error)))
			}
		})
	}

	// MARK: - Public

	// MARK: - Internal

	var configuration: Configuration {
		Configuration.makeDefaultConfiguration(
			serverEnvironmentProvider: serverEnvironmentProvider
		)
	}

	// MARK: - Private

	private let serverEnvironmentProvider: ServerEnvironmentProviding
	private let session: URLSession
	private let packageVerifier: SAPDownloadedPackage.Verification
	private var retries: [URL: Int] = [:]

	private let queue = DispatchQueue(label: "com.sap.HTTPClient")

	private func fetchDay(
		from url: URL,
		completion completeWith: @escaping DayCompletionHandler) {
		var responseError: Failure?
 
		session.GET(url) { [weak self] result in
			self?.queue.async {
				guard let self = self else {
					completeWith(.failure(.noResponse))
					return
				}

				defer {
					// no guard in defer!
					if let error = responseError {
						let retryCount = self.retries[url] ?? 0
						if retryCount > 2 {
							completeWith(.failure(error))
						} else {
							self.retries[url] = retryCount.advanced(by: 1)
							Log.debug("\(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
							self.fetchDay(from: url, completion: completeWith)
						}
					} else {
						// no error, no retry - clean up
						self.retries[url] = nil
					}
				}

				switch result {
				case let .success(response):
					guard let dayData = response.body else {
						responseError = .invalidResponse
						Log.error("Failed to download for URL '\(url)': invalid response", log: .api)
						return
					}
					guard let package = SAPDownloadedPackage(compressedData: dayData) else {
						Log.error("Failed to create signed package. For URL: \(url)", log: .api)
						responseError = .invalidResponse
						return
					}
					let etag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let payload = PackageDownloadResponse(package: package, etag: etag)
					completeWith(.success(payload))
				case let .failure(error):
					responseError = error
					Log.error("Failed to download for URL '\(url)' due to error: \(error).", log: .api)
				}
			}
		}
	}
	
	private func availableDays(
		from url: URL,
		completion completeWith: @escaping AvailableDaysCompletionHandler
	) {
		session.GET(url) { [weak self] result in
			self?.queue.async {
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
	}

	private func otpAuthorizationSuccessHandler(
		for response: URLSession.Response,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let responseBody = response.body else {
			Log.error("Failed to authorize OTP - response error", log: .api)
			Log.error(String(response.statusCode), log: .api)
			completion(.failure(.invalidResponseError))
			return
		}
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let decodedResponse = try decoder.decode(
				OTPResponseProperties.self,
				from: responseBody
			)
			guard let expirationDate = decodedResponse.expirationDate else {
				Log.error("Failed to get expirationDate out of decoded response", log: .api)
				completion(.failure(.invalidResponseError))
				return
			}
			completion(.success(expirationDate))
		} catch {
			Log.error("Failed to get expirationDate because of invalid response payload structure", log: .api)
			completion(.failure(.invalidResponseError))
		}
	}

	private func otpAuthorizationFailureHandler(
		for response: URLSession.Response,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let responseBody = response.body else {
			Log.error("Failed to get authorized OTP - no 200 status code", log: .api)
			Log.error(String(response.statusCode), log: .api)
			completion(.failure(.invalidResponseError))
			return
		}
		do {
			let decodedResponse = try JSONDecoder().decode(
				OTPResponseProperties.self,
				from: responseBody
			)
			guard let errorCode = decodedResponse.errorCode else {
				Log.error("Failed to get errorCode because of invalid response payload structure", log: .api)
				completion(.failure(.invalidResponseError))
				return
			}

			switch errorCode {
			case .API_TOKEN_ALREADY_ISSUED:
				completion(.failure(.apiTokenAlreadyIssued))
			case .API_TOKEN_EXPIRED:
				completion(.failure(.apiTokenExpired))
			case .API_TOKEN_QUOTA_EXCEEDED:
				completion(.failure(.apiTokenQuotaExceeded))
			case .DEVICE_TOKEN_INVALID:
				completion(.failure(.deviceTokenInvalid))
			case .DEVICE_TOKEN_REDEEMED:
				completion(.failure(.deviceTokenRedeemed))
			case .DEVICE_TOKEN_SYNTAX_ERROR:
				completion(.failure(.deviceTokenSyntaxError))
			default:
				completion(.failure(.otherServerError))
			}
		} catch {
			Log.error("Failed to get errorCode because json could not be decoded", log: .api, error: error)
			completion(.failure(.invalidResponseError))
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

	static func keySubmissionRequest(
		configuration: HTTPClient.Configuration,
		payload: CountrySubmissionPayload,
		isFake: Bool
	) throws -> URLRequest { // [KGA]
		// construct the request
		let submPayload = SAP_Internal_SubmissionPayload.with {
			$0.requestPadding = self.getSubmissionPadding(for: payload.exposureKeys)
			$0.keys = payload.exposureKeys
			/// Consent needs always set to be true https://jira.itc.sap.com/browse/EXPOSUREAPP-3125?focusedCommentId=1022122&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-1022122
			$0.consentToFederation = true
			$0.visitedCountries = payload.visitedCountries.map { $0.id }
		}
		let payloadData = try submPayload.serializedData()
		let url = configuration.submissionURL
		var request = URLRequest(url: url)

		// headers
		request.setValue(
			payload.tan,
			// TAN code associated with this diagnosis key submission.
			forHTTPHeaderField: "cwa-authorization"
		)
		
		request.setValue(
			isFake ? "1" : "0",
			// Requests with a value of "0" will be fully processed.
			// Any other value indicates that this request shall be
			// handled as a fake request." ,
			forHTTPHeaderField: "cwa-fake"
		)
		
		// Add header padding for the GUID, in case it is
		// a fake request, otherwise leave empty.
		request.setValue(
			isFake ? String.getRandomString(of: 36) : "",
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

	static func authorizeOTPRequest(
		configuration: HTTPClient.Configuration,
		otp: String,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool
	) throws -> URLRequest {

		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}

		let payload = SAP_Internal_Ppdd_EDUSOneTimePassword.with {
			$0.otp = otp
		}

		let protoBufRequest = SAP_Internal_Ppdd_EDUSOneTimePasswordRequestIOS.with {
			$0.payload = payload
			$0.authentication = ppacIos
		}

		let url = configuration.otpAuthorizationURL
		let body = try protoBufRequest.serializedData()
		var request = URLRequest(url: url)

		request.httpMethod = "POST"

		request.setValue(
			"application/x-protobuf",
			forHTTPHeaderField: "Content-Type"
		)

		#if !RELEASE
		if forceApiTokenHeader {
			request.setValue(
				"1",
				forHTTPHeaderField: "cwa-ppac-ios-accept-api-token"
			)
		}
		#endif

		request.httpBody = body
		return request
	}

	static func ppaSubmit(
		configuration: HTTPClient.Configuration,
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool
	) throws -> URLRequest {

		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}

		let protoBufRequest = SAP_Internal_Ppdd_PPADataRequestIOS.with {
			$0.payload = payload
			$0.authentication = ppacIos
		}

		let url = configuration.ppaSubmitURL
		let body = try protoBufRequest.serializedData()
		var request = URLRequest(url: url)

		request.httpMethod = "POST"

		request.setValue(
			"application/x-protobuf",
			forHTTPHeaderField: "Content-Type"
		)
		
		#if !RELEASE
		if forceApiTokenHeader {
			request.setValue(
				"1",
				forHTTPHeaderField: "cwa-ppac-ios-accept-api-token"
			)
		}
		#endif

		request.httpBody = body
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
	private static func getSubmissionPadding(for keys: [SAP_External_Exposurenotification_TemporaryExposureKey]) -> Data {
		// This parameter denotes how many keys 14 + n have to be padded.
		let n = 0
		let paddedKeysAmount = 14 + n - keys.count
		guard paddedKeysAmount > 0 else { return Data() }
		guard let data = (String.getRandomString(of: 28 * paddedKeysAmount)).data(using: .ascii) else { return Data() }
		return data
	}
	// swiftlint:disable:next file_length
}
