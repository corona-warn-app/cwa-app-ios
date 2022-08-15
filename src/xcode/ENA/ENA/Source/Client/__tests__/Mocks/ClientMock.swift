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
	///		- downloadedPackage: return this value when `fetchDay(_:)` or `fetchHour(_:)` is called, or an error if `urlRequestFailure` is passed.
	///		- submissionError: when set, `submit(_:)` will fail with this error.
	///		- urlRequestFailure: when set, calls (see above) will fail with this error
	init(
		downloadedPackage: PackageDownloadResponse? = nil,
		availablePackageRequestFailure: URLSession.Response.Failure? = nil,
		fetchPackageRequestFailure: URLSession.Response.Failure? = nil
	) {
		self.downloadedPackage = downloadedPackage
		self.availablePackageRequestFailure = availablePackageRequestFailure
		self.fetchPackageRequestFailure = fetchPackageRequestFailure
	}

	init() {}

	// MARK: - Properties.

	var availablePackageRequestFailure: URLSession.Response.Failure?
	var fetchPackageRequestFailure: URLSession.Response.Failure?
	var downloadedPackage: PackageDownloadResponse?
	lazy var supportedCountries: [Country] = {
		// provide a default list of some countries
		let codes = ["DE", "IT", "ES", "PL", "NL", "BE", "CZ", "AT", "DK", "IE", "LT", "LV", "EE"]
		return codes.compactMap({ Country(countryCode: $0) })
	}()

	// MARK: - Configurable Mock Callbacks.

	var onSupportedCountries: ((@escaping CountryFetchCompletion) -> Void)?
	var onGetOTPEdus: ((String, PPACToken, Bool, @escaping OTPAuthorizationCompletionHandler) -> Void)?
	var onGetOTPEls: ((String, PPACToken, @escaping OTPAuthorizationCompletionHandler) -> Void)?
	var onSubmitErrorLog: ((Data, @escaping ErrorLogSubmitting.ELSSubmissionResponse) -> Void)?
	var onSubmitAnalytics: ((SAP_Internal_Ppdd_PPADataIOS, PPACToken, Bool, @escaping PPAnalyticsSubmitionCompletionHandler) -> Void)?
}

extension ClientMock: Client {

	private static let dummyResponse = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))

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

	func submit(
		errorLogFile: Data,
		otpEls: String,
		completion: @escaping ErrorLogSubmitting.ELSSubmissionResponse
	) {
		guard let onSubmitErrorLog = self.onSubmitErrorLog else {
			completion(.success(SubmitELSReceiveModel(id: "\(Int.random(in: 0..<Int.max))", hash: errorLogFile.sha256String())))
			return
		}

		onSubmitErrorLog(errorLogFile, completion)
	}

}
#endif
