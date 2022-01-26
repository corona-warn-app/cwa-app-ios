//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct DCCWalletCertificate: Codable {

	// MARK: - Internal

	struct DCCWalletCertificateCose: Codable {
		let kid: String
	}
	
	let barcodeData: String
	let cose: DCCWalletCertificateCose
	let cwt: CBORWebTokenHeader
	let hcert: DigitalCovidCertificate
	let validityState: String
}
