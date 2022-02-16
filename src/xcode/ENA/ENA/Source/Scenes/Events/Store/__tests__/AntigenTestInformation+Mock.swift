////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension RapidTestQRCodeInformation {
	static func mock(
		hash: String = "f1200d9650f1fd673d58f52811f98f1427fab40b4996e9c2d0da8b7414464086",
		timestamp: Int = 5,
		firstName: String? = nil,
		lastName: String? = nil,
		cryptographicSalt: String? = nil,
		testID: String? = nil,
		dateOfBirth: Date? = nil,
		certificateSupportedByPointOfCare: Bool = false
	) -> Self? {
		RapidTestQRCodeInformation(
			hash: hash,
			timestamp: timestamp,
			firstName: firstName,
			lastName: lastName,
			dateOfBirth: dateOfBirth,
			testID: testID,
			cryptographicSalt: cryptographicSalt,
			certificateSupportedByPointOfCare: certificateSupportedByPointOfCare
		)
	}
}
