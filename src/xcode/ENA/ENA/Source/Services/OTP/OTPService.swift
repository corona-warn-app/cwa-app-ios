////
// 🦠 Corona-Warn-App
//

import Foundation

enum OTPError: Error {
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

		checkAndValidateExistingOTP()

		// if fail -> generate otp

		ppac.getPPACToken({ [weak self] result in
			switch result {
			case .success(let ppacToken):
				// request server for validation of OTP

				self?.authorizeOTP(with: ppacToken, completion: { result in
					switch result {

					case .success(let timestamp):
						self?.updateOTP(with: timestamp)
						guard let token = self?.store.otpToken?.token else {
							// TODO
							return
						}
						completion(.success(token))
					case .failure(let serverError):
						switch serverError {
						case .apiTokenAlreadyIssued:
							completion(.failure(OTPError.apiTokenAlreadyIssued))
						case .apiTokenExpired:
							completion(.failure(OTPError.apiTokenExpired))
						case .apiTokenQuotaExceeded:
							completion(.failure(OTPError.apiTokenQuotaExceeded))
						case .deviceTokenInvalid:
							completion(.failure(OTPError.deviceTokenInvalid))
						case .deviceTokenRedeemed:
							completion(.failure(OTPError.deviceTokenRedeemed))
						case .deviceTokenSyntaxError:
							completion(.failure(OTPError.deviceTokenSyntaxError))
						}
					}
				})

			case .failure(let error):
				switch error {
				case .generationFailed:
					completion(.failure(OTPError.ppacFailed))
				case .deviceNotSupported:
					completion(.failure(OTPError.deviceTokenNotSupported))
				case .timeIncorrect:
					completion(.failure(OTPError.deviceTimeIncorrect))
				case .timeUnverified:
					completion(.failure(OTPError.deviceTimeUnverified))
				}
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

	}

	private func generateAndStoreFreshOTPToken() -> TimestampedToken {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)
		store.otpToken = token
		return token
	}

	private func updateOTP(with newTimestamp: Date) {
		guard let verifiedOTP = store.otpToken?.token else {
			// TODO
			return
		}
		let newToken = TimestampedToken(token: verifiedOTP, timestamp: newTimestamp)
		store.otpToken = newToken
	}

	private func authorizeOTP(with ppacToken: PPACToken, completion: @escaping (Result<Date, OTPServerError>) -> Void) {

		let apiToken = ppacToken.apiToken
		let deviceToken = ppacToken.deviceToken
		let otpToken = store.otpToken

		// request with the three params
	}

}
