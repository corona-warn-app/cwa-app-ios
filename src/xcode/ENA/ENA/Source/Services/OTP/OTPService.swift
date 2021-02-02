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

		// 1. Check for existing otp. If we have none, create one.
		if let token = store.otpToken {
			// 1a: We have a token, check now if it is not from the current month.
			let timestamp = token.timestamp
			guard Calendar.current.isDate(timestamp, equalTo: Date(), toGranularity: .month) else {
				return completion(.failure(OTPError.otpAlreadyUsedThisMonth))
			}
		} else {
			// 1b: We have not aleady a token, generate a new one.
			generateAndStoreFreshOTPToken()
		}

		// 2a Success: We autohorize the otp with the ppacToken at our server.
		authorizeOTP(with: ppacToken, completion: { [weak self] result in

			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError))
				return
			}

			switch result {
			case .success(let timestamp):
				// 3a Success: We store the timestamp of the authorized otp and return the token.
				self.updateOTP(with: timestamp)
				guard let token = self.store.otpToken?.token else {
					Log.error("could not retrieve otp token from store", log: .otp)
					completion(.failure(OTPError.generalError))
					return
				}
				completion(.success(token))
			case .failure(let error):
				// 3b Failure: The server return error. We return that to our caller.
				completion(.failure(error))
			}
		})
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private enum OTPServerError: Error {
		case generalError
		case apiTokenAlreadyIssued
		case apiTokenExpired
		case apiTokenQuotaExceeded
		case deviceTokenInvalid
		case deviceTokenRedeemed
		case deviceTokenSyntaxError
	}

	private let store: Store
	private let client: Client

	private func generateAndStoreFreshOTPToken() {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)
		store.otpToken = token
	}

	private func updateOTP(with newTimestamp: Int) {
		guard let verifiedOTP = store.otpToken?.token else {
			Log.error("could not retrieve otp token from store", log: .otp)
			return
		}
		// TODO we receive Int from the server, but we expected Date. TBA
		let date = Date()
		let newToken = TimestampedToken(token: verifiedOTP, timestamp: date)
		store.otpToken = newToken
	}

	private func authorizeOTP(with ppacToken: PPACToken, completion: @escaping (Result<Int, OTPError>) -> Void) {
		guard let otp = store.otpToken?.token else {
			Log.error("could not retrieve otp token from store", log: .otp)
			completion(.failure(OTPError.generalError))
			return
		}
		client.authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: completion)
	}
}
