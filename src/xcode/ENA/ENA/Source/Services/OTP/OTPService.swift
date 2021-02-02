////
// 🦠 Corona-Warn-App
//

import Foundation

protocol OTPServiceProviding {
	func getValidOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void)
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

	// MARK: - Overrides

	// MARK: - Protocol OTPServiceProviding

	func getValidOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {

		// Check for existing otp. If we have none, create one and proceed.
		if let token = store.otpToken {

			// We have a token, check now if it is not from the current month or the expirationDate is not reeched
			let timestamp = token.timestamp
			if Date() <= token.timestamp {
				guard Calendar.current.isDate(timestamp, equalTo: Date(), toGranularity: .month) else {
					Log.warning("OTP was already used this month", log: .otp)
					return completion(.failure(OTPError.otpAlreadyUsedThisMonth))
				}
				// We have a authorized otp, which is valid and not from this month. So use it.
				return completion(.success(token.token))
			} else {
				// The token has expired, generate a new one and proceed.
				generateAndStoreFreshOTPToken(completion: { [weak self] otp in
					self?.authorize(otp, with: ppacToken, completion: completion)
				})
			}
		} else {
			// We have not aleady a token, generate a new one and proceed.
			generateAndStoreFreshOTPToken(completion: { [weak self] otp in
				self?.authorize(otp, with: ppacToken, completion: completion)
			})
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store
	private let client: Client

	private func generateAndStoreFreshOTPToken(completion: @escaping (String) -> Void ) {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)
		store.otpToken = token
		completion(token.token)
	}

	private func authorize(_ otp: String, with ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {
		
		// We autohorize the otp with the ppacToken at our server.
		client.authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError))
				return
			}

			switch result {
			case .success(let timestamp):
				// Success: We store the timestamp of the authorized otp and return the token.
				guard let verifiedOTP = self.store.otpToken?.token else {
					Log.error("could not retrieve otp token from store", log: .otp)
					completion(.failure(OTPError.generalError))
					return
				}

				guard let date = ISO8601DateFormatter().date(from: timestamp) else {
					Log.error("could not create date from the new timedate", log: .otp)
					completion(.failure(OTPError.generalError))
					return
				}
				let verifiedToken = TimestampedToken(token: verifiedOTP, timestamp: date)
				self.store.otpToken = verifiedToken

				completion(.success(verifiedToken.token))
			case .failure(let error):
				completion(.failure(error))
			}
		})
	}
}
