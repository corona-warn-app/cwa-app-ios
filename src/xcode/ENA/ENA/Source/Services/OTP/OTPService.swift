////
// 🦠 Corona-Warn-App
//

import Foundation

protocol OTPServiceProviding {
	func getValidOTP(_ completion: @escaping (Result<String, Error>) -> Void)
}

final class OTPService: OTPServiceProviding {


	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Overrides

	// MARK: - Protocol OTPServiceProviding

	func getValidOTP(_ completion: @escaping (Result<String, Error>) -> Void) {

		// generates otp

		// stores it in the store

		// get PPACToken

		// requests server for validation of OTP

		// error: pass error to PPAC

		// success: return valid OTP

	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store

}
