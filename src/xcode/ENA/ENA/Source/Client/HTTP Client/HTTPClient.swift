//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

// swiftlint:disable:next type_body_length
final class HTTPClient: Client {

	// MARK: - Init

	init(
		environmentProvider: EnvironmentProviding = Environments(),
		session: URLSession = .coronaWarnSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegateQueue: .main
		)
	) {
		self.environmentProvider = environmentProvider
		self.session = session
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

	func submit(payload: SubmissionPayload, isFake: Bool, completion: @escaping KeySubmissionResponse) {
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
	
	func submitOnBehalf(payload: SubmissionPayload, isFake: Bool, completion: @escaping KeySubmissionResponse) {
		guard let request = try? URLRequest.onBehalfCheckinSubmissionRequest(configuration: configuration, payload: payload, isFake: isFake) else {
			completion(.failure(SubmissionError.requestCouldNotBeBuilt))
			return
		}

		session.response(for: request, isFake: isFake) { result in
			#if !RELEASE
			UserDefaults.standard.dmLastOnBehalfCheckinSubmissionRequest = request.httpBody
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
	
	func traceWarningPackageDiscovery(
		unencrypted: Bool,
		country: String,
		completion: @escaping TraceWarningPackageDiscoveryCompletionHandler
	) {
		guard let request = try? URLRequest.traceWarningPackageDiscovery(
				unencrypted: unencrypted,
				configuration: configuration,
				country: country) else {
			completion(.failure(.requestCreationError))
			return
		}

		session.response(for: request, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					guard let body = response.body else {
						Log.error("Failed to unpack response body of trace warning discovery with http status code: \(String(response.statusCode))", log: .api)
						completion(.failure(.invalidResponseError(response.statusCode)))
						return
					}

					do {
						let decoder = JSONDecoder()
						let decodedResponse = try decoder.decode(
							TraceWarningDiscoveryResponse.self,
							from: body
						)
						let eTag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")

						guard let oldest = decodedResponse.oldest,
							  let latest = decodedResponse.latest else {
							Log.info("Successfully discovered that there are no availablePackagesOnCDN", log: .api)
							// create false package with latest < oldest, then computed property availablePackagesOnCDN will be empty for the downloading check later.
							completion(.success(TraceWarningDiscovery(oldest: 0, latest: -1, eTag: eTag)))
							return
						}

						let traceWarningDiscovery = TraceWarningDiscovery(oldest: oldest, latest: latest, eTag: eTag)
						Log.info("Successfully downloaded availablePackagesOnCDN", log: .api)
						completion(.success(traceWarningDiscovery))
					} catch {
						Log.error("Failed to decode response json", log: .api)
						completion(.failure(.decodingJsonError(response.statusCode)))
					}
				default:
					Log.error("Wrong http status code: \(String(response.statusCode))", log: .api)
					completion(.failure(.invalidResponseError(response.statusCode)))
				}
			case let .failure(error):
				Log.error("Error in response body", log: .api, error: error)
				completion(.failure(.defaultServerError(error)))
			}
		})
	}

	func traceWarningPackageDownload(
		unencrypted: Bool,
		country: String,
		packageId: Int,
		completion: @escaping TraceWarningPackageDownloadCompletionHandler
	) {
		if unencrypted {
			Log.info("unencrypted traceWarningPackageDownload", log: .api)
		} else {
			Log.info("encrypted traceWarningPackageDownload", log: .api)
		}
		let url = unencrypted ?
			configuration.traceWarningPackageDownloadURL(country: country, packageId: packageId) :
			configuration.encryptedTraceWarningPackageDownloadURL(country: country, packageId: packageId)
		traceWarningPackageDownload(country: country, packageId: packageId, url: url, completion: completion)
	}

	// swiftlint:disable:next cyclomatic_complexity
	func dccRegisterPublicKey(
		isFake: Bool = false,
		token: String,
		publicKey: String,
		completion: @escaping DCCRegistrationCompletionHandler
	) {
		guard let request = try? URLRequest.dccPublicKeyRequest(
			configuration: configuration,
			token: token,
			publicKey: publicKey,
			headerValue: isFake ? 1 : 0
		) else {
			Log.error("Failed to create request")
			completion(.failure(.urlCreationFailed))
			return
		}
		session.response(for: request) { [weak self] result in
			self?.queue.async {
				switch result {
				case let .success(response):
					switch response.statusCode {
					case 201:
						completion(.success(()))
					case 400:
						completion(.failure(.badRequest))
					case 403:
						completion(.failure(.tokenNotAllowed))
					case 404:
						completion(.failure(.tokenDoesNotExist))
					case 409:
						completion(.failure(.tokenAlreadyAssigned))
					case 500:
						completion(.failure(.internalServerError))
					default:
						Log.error("Error in response with status code: \(String(response.statusCode))", log: .api)
						completion(.failure(.unhandledResponse(response.statusCode)))
					}
				case let .failure(error):
					if case .noNetworkConnection = error {
						Log.error("No network connection", log: .api)
						completion(.failure(.noNetworkConnection))
					} else {
						Log.error("Error in response body", log: .api, error: error)
						completion(.failure(.defaultServerError(error)))
					}
				}
			}
		}
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
	
	// swiftlint:disable:next cyclomatic_complexity
	func getDigitalCovid19Certificate(
		registrationToken token: String,
		isFake: Bool,
		completion: @escaping DigitalCovid19CertificateCompletionHandler
	) {
		guard let request = try? URLRequest.dccRequest(
				configuration: configuration,
				registrationToken: token,
				headerValue: isFake ? 1 : 0
		) else {
			completion(.failure(.urlCreationFailed))
			return
		}
		
		session.response(for: request, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					guard let responseBody = response.body else {
						Log.error("Error in response body: \(response.statusCode)", log: .api)
						completion(.failure(.unhandledResponse(response.statusCode)))
						return
					}
					do {
						let decodedResponse = try JSONDecoder().decode(
							DCCResponse.self,
							from: responseBody
						)
						completion(.success(decodedResponse))
					} catch {
						Log.error("Failed to decode response json", log: .api, error: error)
						completion(.failure(.jsonError))
					}
				case 202:
					Log.error("HTTP error code 202. DCC is pending.", log: .api)
					completion(.failure(.dccPending))
				case 400:
					Log.error("HTTP error code 400. Bad Request. Perhaps the registration token is wrong formatted?", log: .api)
					completion(.failure(.badRequest))
				case 404:
					Log.error("HTTP error code 404. RegistrationToken does not exist.", log: .api)
					completion(.failure(.tokenDoesNotExist))
				case 410:
					Log.error("HTTP error code 410. DCC is already cleaned up.", log: .api)
					completion(.failure(.dccAlreadyCleanedUp))
				case 412:
					Log.error("HTTP error code 412. Test result not yet received.", log: .api)
					completion(.failure(.testResultNotYetReceived))
				case 500:
					Log.error("HTTP error code 500. Internal server error.", log: .api)
					guard let responseBody = response.body else {
						Log.error("Error in code 500 response body: \(response.statusCode)", log: .api)
						completion(.failure(.unhandledResponse(response.statusCode)))
						return
					}
					do {
						let decodedResponse = try JSONDecoder().decode(
							DCC500Response.self,
							from: responseBody
						)
						completion(.failure(.internalServerError(reason: decodedResponse.reason)))
					} catch {
						Log.error("Failed to decode code 500 response json", log: .api, error: error)
						completion(.failure(.internalServerError(reason: nil)))
					}
				default:
					Log.error("Unhandled http status code: \(String(response.statusCode))", log: .api)
					completion(.failure(.unhandledResponse(response.statusCode)))
				}
			case let .failure(error):
				if case .noNetworkConnection = error {
					Log.error("No network connection", log: .api)
					completion(.failure(.noNetworkConnection))
				} else {
					Log.error("Error in response: \(error)", log: .api)
					completion(.failure(.defaultServerError(error)))
				}
			}
		})
	}
	
	func getBoosterNotificationRules(
		eTag: String? = nil,
		isFake: Bool = false,
		completion: @escaping BoosterRulesCompletionHandler
	) {
		guard let request = try? URLRequest.boosterRulesRequest(
				configuration: configuration,
				eTag: eTag,
				headerValue: isFake ? 1 : 0) else {
			Log.error("Could not create url request for rule type: booster notification", log: .api)
			completion(.failure(.invalidRequest))
			return
		}
		
		session.response(for: request, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					guard let body = response.body else {
						Log.error("Could not get body from response", log: .api)
						completion(.failure(.invalidResponse))
						return
					}
					guard let sapPackage = SAPDownloadedPackage(compressedData: body) else {
						Log.error("Could not create sapPackage", log: .api)
						completion(.failure(.invalidResponse))
						return
					}
					let etag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let packageDownloadResponse = PackageDownloadResponse(package: sapPackage, etag: etag)
					Log.info("Successfully got rules for ruleType: Booster")
					completion(.success(packageDownloadResponse))
				case 304:
					Log.info("Content was not modified - 304.", log: .api)
					completion(.failure(.notModified))
				default:
					Log.error("General server error.", log: .api)
					completion(.failure(.serverError(response.statusCode)))
				}
			case let .failure(error):
				Log.error("Failure at GET for rules of type: Booster.", log: .api, error: error)
				completion(.failure(.invalidResponse))
			}
		})
	}

	@available(*, deprecated, message: "old http client call please use new client")
	func getDCCRules(
		eTag: String? = nil,
		isFake: Bool = false,
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping DCCRulesCompletionHandler
	) {
		guard let request = try? URLRequest.dccRulesRequest(
				ruleType: ruleType,
				configuration: configuration,
				eTag: eTag,
				headerValue: isFake ? 1 : 0) else {
			Log.error("Could not create url request for rule type: \(ruleType)", log: .api)
			completion(.failure(.invalidRequest))
			return
		}
		
		session.response(for: request, completion: { result in
			switch result {
			case let .success(response):
				switch response.statusCode {
				case 200:
					guard let body = response.body else {
						Log.error("Could not get body from response", log: .api)
						completion(.failure(.invalidResponse))
						return
					}
					guard let sapPackage = SAPDownloadedPackage(compressedData: body) else {
						Log.error("Could not create sapPackage", log: .api)
						completion(.failure(.invalidResponse))
						return
					}
					let etag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let packageDownloadResponse = PackageDownloadResponse(package: sapPackage, etag: etag)
					Log.info("Successfully got rules for ruleType: \(ruleType)", log: .api)
					completion(.success(packageDownloadResponse))
				case 304:
					Log.info("Content was not modified - 304.", log: .api)
					completion(.failure(.notModified))
				default:
					Log.error("General server error.", log: .api)
					completion(.failure(.serverError(response.statusCode)))
				}
			case let .failure(error):
				Log.error("Failure at GET for rules of type: \(ruleType).", log: .api, error: error)
				completion(.failure(.invalidResponse))
			}
		})
	}

	// MARK: - Public

	// MARK: - Internal

	lazy var configuration: Configuration = Configuration.makeDefaultConfiguration(environmentProvider: environmentProvider)

	// MARK: - Private

	private let environmentProvider: EnvironmentProviding
	private let session: URLSession
	private let queue = DispatchQueue(label: "com.sap.HTTPClient")

	private var fetchDayRetries: [URL: Int] = [:]
	private var traceWarningPackageDownloadRetries: [URL: Int] = [:]

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
						let retryCount = self.fetchDayRetries[url] ?? 0
						if retryCount > 2 {
							completeWith(.failure(error))
						} else {
							self.fetchDayRetries[url] = retryCount.advanced(by: 1)
							Log.debug("\(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
							self.fetchDay(from: url, completion: completeWith)
						}
					} else {
						// no error, no retry - clean up
						self.fetchDayRetries[url] = nil
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
	
	private func traceWarningPackageDownload(
		country: String,
		packageId: Int,
		url: URL,
		completion: @escaping TraceWarningPackageDownloadCompletionHandler
	) {
		var responseError: TraceWarningError?
		
		session.GET(url) { [weak self] result in
			self?.queue.async {
				
				guard let self = self else {
					Log.error("TraceWarningDownload failed due to strong self creation", log: .api)
					completion(.failure(.generalError))
					return
				}
				
				defer {
					// no guard in defer!
					if let error = responseError {
						let retryCount = self.traceWarningPackageDownloadRetries[url] ?? 0
						if retryCount > 2 {
							completion(.failure(error))
						} else {
							self.traceWarningPackageDownloadRetries[url] = retryCount.advanced(by: 1)
							Log.debug("TraceWarningDownload url: \(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
							self.traceWarningPackageDownload(country: country, packageId: packageId, url: url, completion: completion)
						}
					} else {
						// no error, no retry - clean up
						self.traceWarningPackageDownloadRetries[url] = nil
					}
				}
				
				switch result {
				case let .success(response):
					switch response.statusCode {
					case 200:
						guard let body = response.body else {
							Log.error("Failed to unpack response body of trace warning download with http status code: \(String(response.statusCode))", log: .api)
							responseError = .invalidResponseError(response.statusCode)
							return
						}
						let eTag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
						
						// First look if the response is empty. (i.e. no zip file, to extract).
						// "expectedContentLength" will be -1 if the "content-length" header field is missing.
						if response.httpResponse.expectedContentLength <= 0 {
							let emptyPackage = PackageDownloadResponse(package: nil, etag: eTag)
							Log.info("Successfully downloaded empty traceWarningPackage", log: .api)
							completion(.success(emptyPackage))
						} else {
							guard let package = SAPDownloadedPackage(compressedData: body) else {
								Log.error("Failed to create signed package for trace warning download", log: .api)
								responseError = .invalidResponseError(response.statusCode)
								return
							}
							let downloadedZippedPackage = PackageDownloadResponse(package: package, etag: eTag)
							Log.info("Successfully downloaded zipped traceWarningPackage", log: .api)
							completion(.success(downloadedZippedPackage))
						}
					default:
						Log.error("Error in response with status code: \(String(response.statusCode))", log: .api)
						responseError = .invalidResponseError(response.statusCode)
					}
				case let .failure(error):
					Log.error("Error in response body", log: .api, error: error)
					responseError = .defaultServerError(error)
				}
				
			}
		}
	}

}

// MARK: Extensions

private extension URLRequest {

	static func keySubmissionRequest(
		configuration: HTTPClient.Configuration,
		payload: SubmissionPayload,
		isFake: Bool
	) throws -> URLRequest {
		// construct the request
		let submPayload = SAP_Internal_SubmissionPayload.with {
			$0.requestPadding = self.getSubmissionPadding(for: payload.exposureKeys)
			$0.keys = payload.exposureKeys
			$0.checkIns = payload.checkins
			/// Consent needs always set to be true
			$0.consentToFederation = true
			$0.visitedCountries = payload.visitedCountries.map { $0.id }
			$0.submissionType = payload.submissionType
			$0.checkInProtectedReports = payload.checkinProtectedReports
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
		
		request.httpMethod = HttpMethod.post
		request.httpBody = payloadData
		
		return request
	}
	
	static func onBehalfCheckinSubmissionRequest(
		configuration: HTTPClient.Configuration,
		payload: SubmissionPayload,
		isFake: Bool
	) throws -> URLRequest {
		// construct the request
		let submPayload = SAP_Internal_SubmissionPayload.with {
			$0.requestPadding = self.getSubmissionPadding(for: payload.exposureKeys)
			$0.checkIns = payload.checkins
			$0.checkInProtectedReports = payload.checkinProtectedReports
			$0.consentToFederation = false
			$0.submissionType = payload.submissionType
		}
		let payloadData = try submPayload.serializedData()
		let url = configuration.onBehalfCheckinSubmissionURL
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
		
		request.httpMethod = HttpMethod.post
		request.httpBody = payloadData
		
		return request
	}
	
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

	static func ppaSubmit(
		configuration: HTTPClient.Configuration,
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
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

		request.httpMethod = HttpMethod.post

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

	static func dccPublicKeyRequest(
		configuration: HTTPClient.Configuration,
		token: String,
		publicKey: String,
		headerValue: Int
	) throws -> URLRequest {
		var request = URLRequest(url: configuration.dccPublicKeyURL)

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

		request.httpMethod = HttpMethod.post

		// Add body padding to request.
		let originalBody = [
			"registrationToken": token,
			"publicKey": publicKey
		]

		let paddedData = try getPaddedRequestBody(for: originalBody)
		request.httpBody = paddedData

		return request
	}

	static func traceWarningPackageDiscovery(
		unencrypted: Bool,
		configuration: HTTPClient.Configuration,
		country: String
	) throws -> URLRequest {
		if unencrypted {
			Log.info("unencrypted traceWarningPackageDiscovery", log: .api)
		} else {
			Log.info("encrypted traceWarningPackageDiscovery", log: .api)
		}
		let url = unencrypted ?
			configuration.traceWarningPackageDiscoveryURL(country: country) :
			configuration.encryptedTraceWarningPackageDiscoveryURL(country: country)
		var request = URLRequest(url: url)

		request.httpMethod = HttpMethod.get
		
		return request
	}

	static func dccRequest(
		configuration: HTTPClient.Configuration,
		registrationToken: String,
		headerValue: Int
	) throws -> URLRequest {

		var request = URLRequest(url: configuration.DCCURL)

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

		request.httpMethod = HttpMethod.post

		// Add body padding to request.
		let originalBody = [
			"registrationToken": registrationToken
		]
		let paddedData = try getPaddedRequestBody(for: originalBody)
		request.httpBody = paddedData

		return request
	}
	
	static func boosterRulesRequest(
		configuration: HTTPClient.Configuration,
		eTag: String?,
		headerValue: Int
	) throws -> URLRequest {
		
		var request = URLRequest(url: configuration.boosterRulesURL)
		
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

	@available(*, deprecated, message: "old client stuff")
	static func dccRulesRequest(
		ruleType: HealthCertificateValidationRuleType,
		configuration: HTTPClient.Configuration,
		eTag: String?,
		headerValue: Int
	) throws -> URLRequest {
		
		var request = URLRequest(url: configuration.dccRulesURL(rulePath: ruleType.urlPath))
		
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

	// swiftlint:disable:next file_length
}
