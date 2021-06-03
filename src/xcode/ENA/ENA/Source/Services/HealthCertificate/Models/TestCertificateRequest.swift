////
// 🦠 Corona-Warn-App
//

import Foundation

class TestCertificateRequest: Codable {

	// MARK: - Init

	init(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date,
		rsaKeyPair: DCCRSAKeyPair? = nil,
		rsaPublicKeyRegistered: Bool = false,
		encryptedDEK: String? = nil,
		encryptedCOSE: String? = nil
	) {
		self.coronaTestType = coronaTestType
		self.registrationToken = registrationToken
		self.registrationDate = registrationDate
		self.rsaKeyPair = rsaKeyPair
		self.rsaPublicKeyRegistered = rsaPublicKeyRegistered
		self.encryptedDEK = encryptedDEK
		self.encryptedCOSE = encryptedCOSE
	}

	// MARK: - Internal

	let coronaTestType: CoronaTestType
	let registrationToken: String
	let registrationDate: Date

	var rsaKeyPair: DCCRSAKeyPair?
	var rsaPublicKeyRegistered: Bool

	var encryptedDEK: String?
	var encryptedCOSE: String?

}
