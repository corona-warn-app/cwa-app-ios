////
// 🦠 Corona-Warn-App
//

import Foundation

protocol OTPServiceProviding {
	/// Returns true if we have a stored and authorized otp token, else false.
	var isOTPAvailable: Bool { get }
	/// Checks if there is a valid stored otp. If so, we check if we can reuse it beacuse it was not already used, or if it was already used. If so, we return a failure.  If there is not a stored otp token, or if the stored token's expiration date is reached, a new fresh otp token is generated and stored.
	/// After these validation checks, the service tries to authorize the otp against the server.
	/// - Parameters:
	///   - ppacToken: a generated and valid PPACToken from the PPACService
	///   - completion: The completion handler
	/// - Returns:
	///   - success: the authorized and stored otp as String
	///   - failure: an OTPError, for which the caller can build a dedicated error handling
	func getOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void)
	/// discards any stored otp.
	func discardOTP()
}

final class OTPService: OTPServiceProviding {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		riskProvider: RiskProviding
	) {
		self.store = store
		self.client = client

		self.riskConsumer = RiskConsumer()
		self.riskConsumer.didCalculateRisk = { [weak self] risk in
			if risk.level == .low {
				self?.discardOTP()
			}
		}
		riskProvider.observeRisk(self.riskConsumer)
	}
	
	// MARK: - Protocol OTPServiceProviding

	var isOTPAvailable: Bool {
		store.otpToken != nil
	}

	func getOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		if let otpToken = store.otpToken {
			Log.info("Existing OTP was requested.", log: .otp)
			completion(.success(otpToken.token))
			return
		}

		if isAuthorizedInCurrentMonth {
			Log.warning("The latest successful request for an OTP was in the current month.", log: .otp)
			completion(.failure(OTPError.otpAlreadyUsedThisMonth)) // Fehler
			return
		}

		let otp = generateOTPToken()
		authorize(otp, with: ppacToken, completion: completion)
	}

	func discardOTP() {
		store.otpToken = nil
		Log.info("OTP was discarded.", log: .otp)
	}

	// MARK: - Private

	private let store: Store
	private let client: Client
	private let riskConsumer: RiskConsumer

	private func generateOTPToken() -> String {
		return UUID().uuidString
	}

	private func authorize(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		Log.info("Authorization of a new OTP started.", log: .otp)

		// We autohorize the otp with the ppacToken at our server.

		var ppacHeader = false
		#if !RELEASE
		ppacHeader = store.forceAPITokenAuthorization
		#endif

		client.authorize(otp: otp, ppacToken: ppacToken, isFake: false, ppacHeader: ppacHeader, completion: { [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError))
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

				self.store.otpToken = verifiedToken
				self.store.otpAuthorizationDate = Date()

				Log.info("A new OTP was authorized and persisted.", log: .otp)

				completion(.success(verifiedToken.token))
			case .failure(let error):
				Log.error("Authorization of a new OTP failed with error: \(error)", log: .otp)
				completion(.failure(error))
			}
		})
	}

	var isAuthorizedInCurrentMonth: Bool {
		guard let authorizationDate = store.otpAuthorizationDate else {
			return false
		}
		return authorizationDate.isEqual(to: Date(), toGranularity: .month) &&
			authorizationDate.isEqual(to: Date(), toGranularity: .year)
	}
}
