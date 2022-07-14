//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

final class HTTPClient: Client {

	// MARK: - Init

	init(
		environmentProvider: EnvironmentProviding = Environments(),
		session: URLSession = .legacyCoronaWarnSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegateQueue: .main
		)
	) {
		self.environmentProvider = environmentProvider
		self.session = session
	}

	// MARK: - Protocol Client

	func authorize(
		otpEdus: String,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool = false,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let request = try? URLRequest.authorizeOTPRequest(
				configuration: configuration,
				otpEdus: otpEdus,
				ppacToken: ppacToken,
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

	func authorize(
		otpEls: String,
		ppacToken: PPACToken,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let request = try? URLRequest.authorizeOTPRequest(
				configuration: configuration,
				otpEls: otpEls,
				ppacToken: ppacToken) else {
			completion(.failure(.invalidResponseError))
			return
		}

		session.response(for: request, isFake: false, completion: { [weak self] result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					self?.otpAuthorizationSuccessHandler(for: response, completion: completion)
				case 400, 401, 403:
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
				switch error {
				case .noNetworkConnection:
					completion(.failure(.noNetworkConnection))
				default:
					completion(.failure(.invalidResponseError))
				}
			}
		})
	}

	func submit(
		errorLogFile: Data,
		otpEls: String,
		completion: @escaping ErrorLogSubmitting.ELSSubmissionResponse
	) {
		guard let request = try? URLRequest.errorLogSubmit(
				configuration: configuration,
				payload: errorLogFile,
				otpEls: otpEls) else {
			completion(.failure(.urlCreationError))
			return
		}

		session.response(for: request, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 201:
					guard let responseBody = response.body else {
						Log.error("Error in response body: \(response.statusCode)", log: .api)
						completion(.failure(.responseError(response.statusCode)))
						return
					}
					do {
						let decodedResponse = try JSONDecoder().decode(
							LogUploadResponse.self,
							from: responseBody
						)
						completion(.success(decodedResponse))
					} catch {
						Log.error("Failed to decode response json", log: .api, error: error)
						completion(.failure(.jsonError))
					}
				case 500:
					Log.error("Internal server error at uploading error log file.", log: .api)
					completion(.failure(.responseError(500)))
				default:
					Log.error("Wrong http status code: \(String(response.statusCode))", log: .api)
					completion(.failure(.responseError(response.statusCode)))
				}
			case let .failure(error):
				Log.error("Error in response: \(error)", log: .api)
				completion(.failure(.defaultServerError(error)))
			}
		})
	}
	
	// MARK: - Internal

	lazy var configuration: Configuration = Configuration.makeDefaultConfiguration(environmentProvider: environmentProvider)

	// MARK: - Private

	private let environmentProvider: EnvironmentProviding
	private let session: URLSession
	private let queue = DispatchQueue(label: "com.sap.HTTPClient")

	private var fetchDayRetries: [URL: Int] = [:]
	private var traceWarningPackageDownloadRetries: [URL: Int] = [:]

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
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let decodedResponse = try decoder.decode(
				OTPResponseProperties.self,
				from: responseBody
			)
			guard let errorCode = decodedResponse.errorCode else {
				Log.error("Failed to get errorCode because it is nil", log: .api)
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

private extension URLRequest {
	
	static func authorizeOTPRequest(
		configuration: HTTPClient.Configuration,
		otpEdus: String,
		ppacToken: PPACToken,
		forceApiTokenHeader: Bool,
		isFake: Bool = false
	) throws -> URLRequest {
		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}

		let payload = SAP_Internal_Ppdd_EDUSOneTimePassword.with {
			$0.otp = otpEdus
		}

		let protoBufRequest = SAP_Internal_Ppdd_EDUSOneTimePasswordRequestIOS.with {
			$0.payload = payload
			$0.authentication = ppacIos
		}

		let url = configuration.otpEdusAuthorizationURL
		let body = try protoBufRequest.serializedData()
		var request = URLRequest(url: url)

		request.httpMethod = HttpMethod.post

		request.setValue(
			"application/x-protobuf",
			forHTTPHeaderField: "Content-Type"
		)

		request.setValue(
			isFake ? "1" : "0",
			forHTTPHeaderField: "cwa-fake"
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

	static func authorizeOTPRequest(
		configuration: HTTPClient.Configuration,
		otpEls: String,
		ppacToken: PPACToken
	) throws -> URLRequest {
		let ppacIos = SAP_Internal_Ppdd_PPACIOS.with {
			$0.apiToken = ppacToken.apiToken
			$0.deviceToken = ppacToken.deviceToken
		}

		let payload = SAP_Internal_Ppdd_ELSOneTimePassword.with {
			$0.otp = otpEls
		}

		let protoBufRequest = SAP_Internal_Ppdd_ELSOneTimePasswordRequestIOS.with {
			$0.payload = payload
			$0.authentication = ppacIos
		}
		
		let url = configuration.otpElsAuthorizationURL
		let body = try protoBufRequest.serializedData()
		var request = URLRequest(url: url)

		request.httpMethod = HttpMethod.post

		// Headers
		request.setValue(
			"application/x-protobuf",
			forHTTPHeaderField: "Content-Type"
		)
		
		request.setValue(
			"0",
			forHTTPHeaderField: "cwa-fake"
		)
		
		request.httpBody = body
		return request
	}


	static func errorLogSubmit(
		configuration: HTTPClient.Configuration,
		payload: Data,
		otpEls: String
	) throws -> URLRequest {
		let boundary = UUID().uuidString
		var request = URLRequest(url: configuration.logUploadURL)
		request.httpMethod = HttpMethod.post
		
		// Create multipart body
		
		// prevent potential file collisions on backend
		let fileName = "ErrorLog-\(UUID().uuidString).zip"
		
		var body = Data()

		try body.append("\r\n--\(boundary)\r\n")
		try body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
		try body.append("Content-Type:application/zip\r\n")
		try body.append("Content-Length: \(payload.count)\r\n")
		try body.append("\r\n")
		body.append(payload)
		try body.append("\r\n")
		try body.append("--\(boundary)--\r\n")
		
		request.httpBody = body
		
		// Create headers
		
		request.setValue(
			"multipart/form-data; boundary=\(boundary)",
			forHTTPHeaderField: "Content-Type"
		)
		
		request.setValue(
			otpEls,
			forHTTPHeaderField: "cwa-otp"
		)
		
		request.setValue(
			"\(body.count)",
			forHTTPHeaderField: "Content-Length"
		)
		
		return request
	}

	static func dscListRequest(
		configuration: HTTPClient.Configuration,
		eTag: String?,
		headerValue: Int
	) -> URLRequest {
		var request = URLRequest(url: configuration.DSCListURL)

		if let eTag = eTag {
			request.setValue(
				eTag,
				forHTTPHeaderField: "If-None-Match"
			)
		}
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

		request.httpMethod = HttpMethod.get
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
		let padding = String.getRandomString(of: max(0, paddingSize))
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

}
