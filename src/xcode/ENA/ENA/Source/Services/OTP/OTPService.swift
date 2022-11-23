////
// 🦠 Corona-Warn-App
//

import Foundation

protocol OTPServiceProviding {
	/// Returns true if we have a stored and authorized otp edus token, else false.
	var isOTPEdusAvailable: Bool { get }
	
	/// Checks if there is a valid stored otp for edus. If so, we check if we can reuse it because it was not already used, or if it was already used. If so, we return a failure.  If there is not a stored otp edus token, or if the stored token's expiration date is reached, a new fresh otp token is generated and stored.
	/// After these validation checks, the service tries to authorize the otp against the server.
	/// - Parameters:
	///   - ppacToken: a generated and valid PPACToken from the PPACService
	///   - completion: The completion handler
	/// - Returns:
	///   - success: the authorized and stored otp as String
	///   - failure: an OTPError, for which the caller can build a dedicated error handling
	func getOTPEdus(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void)
	
	/// Checks if there is a valid stored otp for els. If so, we check if we can reuse it because it was not already used, or if it was already used. If so, we return a failure.  If there is not a stored otp els token, or if the stored token's expiration date is reached, a new fresh otp token is generated and stored.
	/// After these validation checks, the service tries to authorize the otp against the server.
	/// - Parameters:
	///   - ppacToken: a generated and valid PPACToken from the PPACService
	///   - completion: The completion handler
	/// - Returns:
	///   - success: the authorized and stored otp as String
	///   - failure: an OTPError, for which the caller can build a dedicated error handling
	func getOTPEls(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void)
	
	/// Checks if there is a valid stored otp for SRS. If so, we check if we can reuse it because it was not already used, or if it was already used. If so, we return a failure.  If there is not a stored otp els token, or if the stored token's expiration date is reached, a new fresh otp token is generated and stored.
	/// After these validation checks, the service tries to authorize the otp against the server.
	/// - Parameters:
	///   - ppacToken: a generated and valid PPACToken from the PPACService
	///   - completion: The completion handler
	/// - Returns:
	///   - success: the authorized and stored otp as String
	///   - failure: an OTPError, for which the caller can build a dedicated error handling
	func getOTPSRS(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void)
	/// discards any stored otp edus.
	func discardOTPEdus()
	/// discards any stored otp els.
	func discardOTPEls()
}

final class OTPService: OTPServiceProviding {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		restServiceProvider: RestServiceProviding,
		riskProvider: RiskProviding
	) {
		self.store = store
		self.client = client
		self.restServiceProvider = restServiceProvider
		
		self.riskConsumer = RiskConsumer()
		self.riskConsumer.didCalculateRisk = { [weak self] risk in
			if risk.level == .low {
				self?.discardOTPEdus()
			}
		}
		riskProvider.observeRisk(self.riskConsumer)
	}
	
	// MARK: - Protocol OTPServiceProviding

	var isOTPEdusAvailable: Bool {
		store.otpTokenEdus != nil
	}

	func getOTPEdus(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		if let otpToken = store.otpTokenEdus {
			Log.info("Existing OTP EDUS was requested.", log: .otp)
			completion(.success(otpToken.token))
			return
		}

		if isAuthorizedInCurrentMonth {
			Log.warning("The latest successful request for an OTP EDUS was in the current month.", log: .otp)
			completion(.failure(OTPError.otpAlreadyUsedThisMonth)) // Fehler
			return
		}
		
		Log.info("NO existing OTP EDUS was found. Generating new one.", log: .otp)
		let otp = generateOTPToken()
		authorizeEdus(otp, with: ppacToken, completion: completion)
	}
	
	func getOTPEls(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		// take existing OTP only if it's expirationDate has not exceeded and when it was not authorized.
		if let otpToken = store.otpTokenEls,
		   let expirationDate = otpToken.expirationDate,
		   expirationDate > Date(),
		   store.otpElsAuthorizationDate == nil {
			Log.info("Existing OTP ELS was not consumed before and can be used for submission.", log: .otp)
			completion(.success(otpToken.token))
			return
		}
		Log.info("No existing or valid OTP ELS was found. Generating new one.", log: .otp)
		let otp = generateOTPToken()
		authorizeEls(otp, with: ppacToken, completion: completion)
	}

	func getOTPSRS(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		if let otpToken = store.otpTokenSrs,
		   let expirationDate = otpToken.expirationDate,
		   expirationDate > Date(),
		   store.otpElsAuthorizationDate == nil {
			Log.info("Existing OTP ELS was not consumed before and can be used for submission.", log: .otp)
			completion(.success(otpToken.token))
			return
		}
		Log.info("No existing or valid OTP ELS was found. Generating new one.", log: .otp)
		let otp = generateOTPToken()
		authorizeSRS(otp, with: ppacToken, completion: completion)
	}

	func discardOTPEdus() {
		store.otpTokenEdus = nil
		Log.info("OTP EDUS was discarded.", log: .otp)
	}
	
	func discardOTPEls() {
		store.otpTokenEls = nil
		Log.info("OTP ELS was discarded.", log: .otp)
	}

	// MARK: - Private

	private let store: Store
	private let client: Client
	private let restServiceProvider: RestServiceProviding
	private let riskConsumer: RiskConsumer
	
	private var isAuthorizedInCurrentMonth: Bool {
		guard let authorizationDate = store.otpEdusAuthorizationDate else {
			return false
		}
		return authorizationDate.isEqual(to: Date(), toGranularity: .month) &&
			authorizationDate.isEqual(to: Date(), toGranularity: .year)
	}

	private func generateOTPToken() -> String {
		return UUID().uuidString
	}

	private func authorizeEdus(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		Log.info("Authorization of a new OTP EDUS started.", log: .otp)

		// We autohorize the otp with the ppacToken at our server.
		var forceApiTokenHeader = false
		#if !RELEASE
		forceApiTokenHeader = store.forceAPITokenAuthorization
		#endif

		client.authorize(otpEdus: otp, ppacToken: ppacToken, isFake: false, forceApiTokenHeader: forceApiTokenHeader, completion: { [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError(underlyingError: nil)))
				return
			}

			switch result {
			case .success(let expirationDate):
				// Success: We store the authorized otp with timestamp and return the token.
				let verifiedToken = OTPToken(
					token: otp,
					timestamp: Date(),
					expirationDate: expirationDate
				)

				self.store.otpTokenEdus = verifiedToken
				self.store.otpEdusAuthorizationDate = Date()

				Log.info("A new OTP EDUS was authorized and persisted.", log: .otp)

				completion(.success(verifiedToken.token))
			case .failure(let error):
				Log.error("Authorization of a new OTP EDUS failed with error: \(error)", log: .otp)
				completion(.failure(error))
			}
		})
	}
	
	private func authorizeEls(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		Log.info("Authorization of a new OTP ELS started.", log: .otp)
		// We autohorize the otp with the ppacToken at our server.
		let resource = OTPAuthorizationForELSResource(otpEls: otp, ppacToken: ppacToken)
		restServiceProvider.load(resource) { [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError(underlyingError: nil)))
				return
			}

			switch result {
			case .success(let expirationDate):
				// Success: We store the authorized otp with timestamp and return the token.
				let verifiedToken = OTPToken(
					token: otp,
					timestamp: Date(),
					expirationDate: expirationDate.expirationDate
				)

				self.store.otpTokenEls = verifiedToken

				Log.info("A new OTP ELS was authorized and persisted.", log: .otp)

				completion(.success(verifiedToken.token))
			case .failure(let error):
				Log.error("Authorization of a new OTP ELS failed with error: \(error)", log: .otp)
				completion(.failure(.restServiceError(error)))
			}
		}
	}
	
	private func authorizeSRS(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		Log.info("Authorization of a new OTP SRS started.", log: .otp)
		// We authorize the otp with the ppac Token at our server.
		let resource = OTPAuthorizationForSRSResource(otpSRS: otp, ppacToken: ppacToken)
		restServiceProvider.load(resource) { [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError(underlyingError: nil)))
				return
			}

			switch result {
			case .success(let expirationDate):
				// Success: We store the authorized otp with timestamp and return the token.
				let verifiedToken = OTPToken(
					token: otp,
					timestamp: Date(),
					expirationDate: expirationDate.expirationDate
				)

				self.store.otpTokenEls = verifiedToken

				Log.info("A new OTP ELS was authorized and persisted.", log: .otp)

				completion(.success(verifiedToken.token))
			case .failure(let error):
                
				Log.error("Authorization of a new OTP SRS failed with error: \(error)", log: .otp)
				completion(.failure(.restServiceError(error)))
			}
		}
	}
}
