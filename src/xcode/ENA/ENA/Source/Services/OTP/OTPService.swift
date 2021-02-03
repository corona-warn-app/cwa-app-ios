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

	// MARK: - Protocol OTPServiceProviding

	func getValidOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {

		// Check for existing otp. If we have none, create one and proceed.
		if let token = store.otpToken {

			// We have a token, check now if it is not from the current month or the expirationDate is not reeched
			guard let expirationDate = token.expirationDate else {
				Log.error("could not create date of tokens expirationDate", log: .otp)
				completion(.failure(OTPError.generalError))
				return
			}
			if Date() <= expirationDate {
				guard !expirationDate.isEqual(to: Date(), toGranularity: .month),
					  !expirationDate.isEqual(to: Date(), toGranularity: .year) else {
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

	// MARK: - Private

	private let store: Store
	private let client: Client

	private func generateAndStoreFreshOTPToken(completion: @escaping (String) -> Void ) {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = OTPToken(token: uuid, timestamp: utcDate, expirationDate: nil)
		store.otpToken = token
		completion(token.token)
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
			case .success(let timestamp):
				// Success: We store the timestamp of the authorized otp and return the token.
				guard let verifiedOTP = self.store.otpToken else {
					Log.error("could not retrieve otp token from store", log: .otp)
					completion(.failure(OTPError.generalError))
					return
				}

				let verifiedToken = OTPToken(token: verifiedOTP.token, timestamp: verifiedOTP.timestamp, expirationDate: timestamp)
				self.store.otpToken = verifiedToken

				completion(.success(verifiedToken.token))
			case .failure(let error):
				completion(.failure(error))
			}
		})
	}
}
