////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class OTPServiceMock: OTPServiceProviding {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol OTPServiceProviding

	func getValidOTP(ppacToken: PPACToken, completion: @escaping (Result<String, OTPError>) -> Void) {


	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
}
