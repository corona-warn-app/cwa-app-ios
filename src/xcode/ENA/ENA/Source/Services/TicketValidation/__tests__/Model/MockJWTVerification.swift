//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import ENASecurity
@testable import ENA

class MockJWTVerification: JWTVerifying {

	init(result: Result<Void, JWTVerificationError>? = nil) {
		self.result = result
	}

	var result: Result<Void, JWTVerificationError>?

	func verify(jwtString: String, against jwkSet: [JSONWebKey]) -> Result<Void, JWTVerificationError> {
		return result ?? .success(())
	}

}
