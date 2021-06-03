////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestCertificateRequest: Codable {

	let coronaTestType: CoronaTestType
	let registrationToken: String
	let registrationDate: Date

	var rsaKeyPair: DCCRSAKeyPair?
	var rsaPublicKeyRegistered: Bool

	var encryptedDEK: String?
	var encryptedCOSE: String?

}
