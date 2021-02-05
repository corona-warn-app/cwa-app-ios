////
// 🦠 Corona-Warn-App
//

import Foundation

protocol OTPServiceProviding {
	/// Returns true if we have a stored and authorized otp token. If it is not authorized or we do not have one stored, we return false
	var isStoredOTPAuthorized: Bool { get }
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
		client: Client
	) {
		self.store = store
		self.client = client
	}
	
	// MARK: - Protocol OTPServiceProviding

	var isStoredOTPAuthorized: Bool {
		return store.otpToken?.expirationDate != nil ? true : false
	}

	func getOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		// Check for existing otp. If we have none, create one and proceed.
		if let token = store.otpToken {

			guard !token.isAuthorizedInCurrentMonth else {
				Log.error("The latest successful request for an OTP was in the current month.", log: .otp)
				completion(.failure(OTPError.otpAlreadyUsedThisMonth))
				return
			}

			let otp = generateAndStoreFreshOTPToken()
			authorize(otp, with: ppacToken, completion: completion)

		} else {
			let otp = generateAndStoreFreshOTPToken()
			authorize(otp, with: ppacToken, completion: completion)
		}
	}

	func discardOTP() {
		store.otpToken = nil
		Log.info("OTP was discarded.", log: .otp)
	}

	// MARK: - Private

	private let store: Store
	private let client: Client

	private func generateAndStoreFreshOTPToken() -> String {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = OTPToken(token: uuid, timestamp: utcDate, expirationDate: nil, authorizationDate: nil)
		store.otpToken = token
		return token.token
	}

	private func authorize(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		
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
				// Success: We store the timestamp of the authorized otp and return the token.
				guard let verifiedOTP = self.store.otpToken else {
					Log.error("could not retrieve otp token from store", log: .otp)
					completion(.failure(OTPError.generalError))
					return
				}

				let verifiedToken = OTPToken(
					token: verifiedOTP.token,
					timestamp: verifiedOTP.timestamp,
					expirationDate: expirationDate,
					authorizationDate: Date()
				)

				self.store.otpToken = verifiedToken

				completion(.success(verifiedToken.token))
			case .failure(let error):
				completion(.failure(error))
			}
		})
	}
}

fileprivate extension OTPToken {

	var isAuthorized: Bool {
		return expirationDate != nil
	}

	var isExpired: Bool {
		guard let expirationDate = expirationDate else {
			return true
		}
		return expirationDate < Date()
	}

	var isAuthorizedInCurrentMonth: Bool {
		guard let authorizationDate = authorizationDate else {
			return false
		}
		return authorizationDate.isEqual(to: Date(), toGranularity: .month) &&
			authorizationDate.isEqual(to: Date(), toGranularity: .year)
	}
}
