////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct CoronaTestCertificateRequest: Codable {

	let coronaTestType: CoronaTestType
	let registrationToken: String
	let registrationDate: Date

	var rsaKeyPair: DCCRSAKeyPair?
	var rsaPublicKeyRegistered: Bool

	var encryptedDEK: Data?
	var encryptedCOSE: Data?

}
