////
// 🦠 Corona-Warn-App
//

import Foundation

enum OTPError: Error {
	case generalError
	case ppacFailed
	case apiTokenAlreadyIssued
	case apiTokenExpired
	case apiTokenQuotaExceeded
	case deviceTokenInvalid
	case deviceTokenRedeemed
	case deviceTokenSyntaxError
	case deviceTokenNotSupported
	case deviceTimeIncorrect
	case deviceTimeUnverified
}

protocol OTPServiceProviding {
	func getValidOTP(completion: @escaping (Result<String, Error>) -> Void)
}

final class OTPService: OTPServiceProviding {


	// MARK: - Init

	init(store: Store) throws {
		self.store = store
		do {
			self.ppac = try PrivacyPreservingAccessControlService(store: store)
		} catch {
			throw OTPError.ppacFailed
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol OTPServiceProviding

	func getValidOTP(completion: @escaping (Result<String, Error>) -> Void) {

		// 1. check for existing otp. If we have none, create one.
		checkAndValidateExistingOTP()

		// 2. get ppacToken from ppacService.
		ppac.getPPACToken({ [weak self] result in
			guard let self = self else {
				Log.error("could not create strong self", log: .otp)
				completion(.failure(OTPError.generalError))
				return
			}

			switch result {
			case .success(let ppacToken):
				// 3a Success: We autohorize the otp with the ppacToken at our server.
				self.authorizeOTP(with: ppacToken, completion: { result in
					switch result {
					case .success(let timestamp):
						// 4a Success: We store the timestamp of the authorized otp and return the token.
						self.updateOTP(with: timestamp)
						guard let token = self.store.otpToken?.token else {
							Log.error("could not retrieve otp from store", log: .otp)
							completion(.failure(OTPError.generalError))
							return
						}
						completion(.success(token))
					case .failure(let serverError):
						// 4b Failure: The server return error. We return that to our caller.
						completion(.failure(self.otpError(from: serverError)))
					}
				})

			case .failure(let ppacError):
				// 3b Failure: Getting a ppacToken failed, so return the error.
				completion(.failure(self.otpError(from: ppacError)))

			}

		})
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private enum OTPServerError: Error {
		case apiTokenAlreadyIssued
		case apiTokenExpired
		case apiTokenQuotaExceeded
		case deviceTokenInvalid
		case deviceTokenRedeemed
		case deviceTokenSyntaxError
	}

	private let store: Store
	private let ppac: PrivacyPreservingAccessControl

	private func checkAndValidateExistingOTP() {
		// TODO validation check
		// check if none there otherwise
		generateAndStoreFreshOTPToken()
	}

	private func generateAndStoreFreshOTPToken() {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)
		store.otpToken = token
	}

	private func updateOTP(with newTimestamp: Date) {
		guard let verifiedOTP = store.otpToken?.token else {
			Log.error("could not retrieve otp from store", log: .otp)
			return
		}
		let newToken = TimestampedToken(token: verifiedOTP, timestamp: newTimestamp)
		store.otpToken = newToken
	}

	private func authorizeOTP(with ppacToken: PPACToken, completion: @escaping (Result<Date, OTPServerError>) -> Void) {
		// TODO request
		let apiToken = ppacToken.apiToken
		let deviceToken = ppacToken.deviceToken
		let otpToken = store.otpToken

		// request with the three params
	}

	private func otpError(from serverError: OTPServerError) -> OTPError {
		switch serverError {
		case .apiTokenAlreadyIssued:
			return OTPError.apiTokenAlreadyIssued
		case .apiTokenExpired:
			return OTPError.apiTokenExpired
		case .apiTokenQuotaExceeded:
			return OTPError.apiTokenQuotaExceeded
		case .deviceTokenInvalid:
			 return OTPError.deviceTokenInvalid
		case .deviceTokenRedeemed:
			return OTPError.deviceTokenRedeemed
		case .deviceTokenSyntaxError:
			return OTPError.deviceTokenSyntaxError
		}
	}

	private func otpError(from ppacError: PPACError) -> OTPError {
		switch ppacError {
		case .generationFailed:
			return OTPError.ppacFailed
		case .deviceNotSupported:
			return OTPError.deviceTokenNotSupported
		case .timeIncorrect:
			 return OTPError.deviceTimeIncorrect
		case .timeUnverified:
			return OTPError.deviceTimeUnverified
		}
	}

}
