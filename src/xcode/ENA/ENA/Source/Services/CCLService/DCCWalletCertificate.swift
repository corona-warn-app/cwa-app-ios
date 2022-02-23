//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct DCCWalletCertificateCose: Codable {
	
	// MARK: - Internal

	let kid: String
}

struct DCCWalletCertificate: Codable {

	// MARK: - Internal
	
	let barcodeData: String
	let cose: DCCWalletCertificateCose
	let cwt: CBORWebTokenHeader
	let hcert: DigitalCovidCertificate
	let validityState: String
}
