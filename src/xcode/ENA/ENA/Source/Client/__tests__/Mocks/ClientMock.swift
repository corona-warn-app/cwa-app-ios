//
// 🦠 Corona-Warn-App
//

import ExposureNotification

#if DEBUG

final class ClientMock {
	
	// MARK: - Creating a Mock Client.

	/// Creates a mock `Client` implementation with given default values.
	///
	/// - parameters:
	///		- availableDaysAndHours: return this value when the `availableDays(_:)` or `availableHours(_:)` is called, or an error if `urlRequestFailure` is passed.
	///		- downloadedPackage: return this value when `fetchDay(_:)` or `fetchHour(_:)` is called, or an error if `urlRequestFailure` is passed.
	///		- submissionError: when set, `submit(_:)` will fail with this error.
	///		- urlRequestFailure: when set, calls (see above) will fail with this error
	init(
		availableDaysAndHours: DaysAndHours = DaysAndHours(days: [], hours: []),
		downloadedPackage: PackageDownloadResponse? = nil,
		submissionError: SubmissionError? = nil,
		availablePackageRequestFailure: Client.Failure? = nil,
		fetchPackageRequestFailure: Client.Failure? = nil
	) {
		self.availableDaysAndHours = availableDaysAndHours
		self.downloadedPackage = downloadedPackage
		self.availablePackageRequestFailure = availablePackageRequestFailure
		self.fetchPackageRequestFailure = fetchPackageRequestFailure

		if let error = submissionError {
			onSubmitCountries = { $2(.failure(error)) }
		}
	}

	init() {}

	// MARK: - Properties.

	var submissionResponse: KeySubmissionResponse?
	var availablePackageRequestFailure: Client.Failure?
	var fetchPackageRequestFailure: Client.Failure?
	var availableDaysAndHours: DaysAndHours = DaysAndHours(days: [], hours: [])
	var downloadedPackage: PackageDownloadResponse?
	lazy var supportedCountries: [Country] = {
		// provide a default list of some countries
		let codes = ["DE", "IT", "ES", "PL", "NL", "BE", "CZ", "AT", "DK", "IE", "LT", "LV", "EE"]
		return codes.compactMap({ Country(countryCode: $0) })
	}()

	// MARK: - Configurable Mock Callbacks.

	var onGetTestResult: ((String, Bool, TestResultHandler) -> Void)?
	var onSubmitCountries: ((_ payload: CountrySubmissionPayload, _ isFake: Bool, _ completion: @escaping KeySubmissionResponse) -> Void) = { $2(.success(())) }
	var onGetRegistrationToken: ((String, String, String?, Bool, @escaping RegistrationHandler) -> Void)?
	var onGetTANForExposureSubmit: ((String, Bool, @escaping TANHandler) -> Void)?
	var onSupportedCountries: ((@escaping CountryFetchCompletion) -> Void)?
	var onGetOTPEdus: ((String, PPACToken, Bool, @escaping OTPAuthorizationCompletionHandler) -> Void)?
	var onGetOTPEls: ((String, PPACToken, @escaping OTPAuthorizationCompletionHandler) -> Void)?
	var onSubmitErrorLog: ((Data, @escaping ErrorLogSubmitting.ELSSubmissionResponse) -> Void)?
	var onSubmitAnalytics: ((SAP_Internal_Ppdd_PPADataIOS, PPACToken, Bool, @escaping PPAnalyticsSubmitionCompletionHandler) -> Void)?
	var onTraceWarningDiscovery: ((String, @escaping TraceWarningPackageDiscoveryCompletionHandler) -> Void)?
	var onTraceWarningDownload: ((String, Int, @escaping TraceWarningPackageDownloadCompletionHandler) -> Void)?
	var onDCCRegisterPublicKey: ((Bool, String, String, @escaping DCCRegistrationCompletionHandler) -> Void)?
	var onGetDigitalCovid19Certificate: ((String, Bool, @escaping DigitalCovid19CertificateCompletionHandler) -> Void)?
}

extension ClientMock: ClientWifiOnly {

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: PackageDownloadResponse]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			fetchHour(hour, day: day, country: country) { result in
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

	func fetchHour(_ hour: Int, day: String, country: String, completion: @escaping HourCompletionHandler) {
		if let failure = fetchPackageRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(downloadedPackage ?? ClientMock.dummyResponse))
	}

}

extension ClientMock: Client {

	private static let dummyResponse = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()), etag: "\"etag\"")

	func availableDays(forCountry country: String, completion: @escaping AvailableDaysCompletionHandler) {
		if let failure = availablePackageRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(availableDaysAndHours.days))
	}

	func availableHours(day: String, country: String, completion: @escaping AvailableHoursCompletionHandler) {
		if let failure = availablePackageRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(availableDaysAndHours.hours))
	}

	func fetchDay(_ day: String, forCountry country: String, completion: @escaping DayCompletionHandler) {
		if let failure = fetchPackageRequestFailure {
			completion(.failure(failure))
			return
		}
		completion(.success(downloadedPackage ?? ClientMock.dummyResponse))
	}

	func submit(payload: CountrySubmissionPayload, isFake: Bool, completion: @escaping KeySubmissionResponse) {
		onSubmitCountries(payload, isFake, completion)
	}

	func getRegistrationToken(
		forKey: String,
		withType: String,
		dateOfBirthKey: String?,
		isFake: Bool,
		completion completeWith: @escaping RegistrationHandler
	) {
		guard let onGetRegistrationToken = self.onGetRegistrationToken else {
			completeWith(.success("dummyRegistrationToken"))
			return
		}

		onGetRegistrationToken(forKey, withType, dateOfBirthKey, isFake, completeWith)
	}

	func getTestResult(forDevice device: String, isFake: Bool, completion completeWith: @escaping TestResultHandler) {
		guard let onGetTestResult = self.onGetTestResult else {
			completeWith(.success(FetchTestResultResponse(testResult: TestResult.positive.rawValue, sc: nil)))
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

	func authorize(
		otpEdus: String,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool = false,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let onGetOTPEdus = self.onGetOTPEdus else {
			completion(.success(Date()))
			return
		}
		onGetOTPEdus(otpEdus, ppacToken, isFake, completion)
	}

	func authorize(
		otpEls: String,
		ppacToken: PPACToken,
		completion: @escaping OTPAuthorizationCompletionHandler
	) {
		guard let onGetOTPEls = self.onGetOTPEls else {
			completion(.success(Date()))
			return
		}

		onGetOTPEls(otpEls, ppacToken, completion)
	}

	func submit(
		payload: SAP_Internal_Ppdd_PPADataIOS,
		ppacToken: PPACToken,
		isFake: Bool,
		forceApiTokenHeader: Bool,
		completion: @escaping PPAnalyticsSubmitionCompletionHandler
	) {
		guard let onSubmitAnalytics = self.onSubmitAnalytics else {
			completion(.success(()))
			return
		}
		onSubmitAnalytics(payload, ppacToken, isFake, completion)
	}
	
	func traceWarningPackageDiscovery(
		country: String,
		completion: @escaping TraceWarningPackageDiscoveryCompletionHandler
	) {
		guard let onTraceWarningDiscovery = self.onTraceWarningDiscovery else {
			completion(.success((TraceWarningDiscovery(oldest: 448163, latest: 448522, eTag: "FakeETag"))))
			return
		}
		onTraceWarningDiscovery(country, completion)
	}
	
	func traceWarningPackageDownload(
		country: String,
		packageId: Int,
		completion: @escaping TraceWarningPackageDownloadCompletionHandler
	) {
		guard let onTraceWarningDownload = self.onTraceWarningDownload else {
			completion(.success(downloadedPackage ?? ClientMock.dummyResponse))
			return
		}
		onTraceWarningDownload(country, packageId, completion)
	}

	func dccRegisterPublicKey(
		isFake: Bool,
		token: String,
		publicKey: String,
		completion: @escaping DCCRegistrationCompletionHandler
	) {
		guard let onDCCRegisterPublicKey = self.onDCCRegisterPublicKey else {
			completion(.success(()))
			return
		}
		onDCCRegisterPublicKey(isFake, token, publicKey, completion)
	}

	func submit(
		errorLogFile: Data,
		otpEls: String,
		completion: @escaping ErrorLogSubmitting.ELSSubmissionResponse
	) {
		guard let onSubmitErrorLog = self.onSubmitErrorLog else {
			completion(.success(LogUploadResponse(id: "\(Int.random(in: 0..<Int.max))", hash: errorLogFile.sha256String())))
			return
		}

		onSubmitErrorLog(errorLogFile, completion)
	}
	
	func getDigitalCovid19Certificate(
		registrationToken token: String,
		isFake: Bool,
		completion: @escaping DigitalCovid19CertificateCompletionHandler

	) {
		guard let onGetDigitalCovid19Certificate = self.onGetDigitalCovid19Certificate else {
			completion(.success((DCCResponse(dek: "dataEncryptionKey", dcc: "coseObject"))))
			return
		}
		onGetDigitalCovid19Certificate(token, isFake, completion)
	}
}
#endif
