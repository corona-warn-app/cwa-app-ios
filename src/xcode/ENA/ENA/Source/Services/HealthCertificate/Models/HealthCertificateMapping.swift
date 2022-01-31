//
// 🦠 Corona-Warn-App
//

import Foundation

extension HealthCertificateValidityState {
	var identifier: String {
		switch self {
		case .valid:
			return "VALID"
		case .expiringSoon:
			return "EXPIRING_SOON"
		case .expired:
			return "EXPIRED"
		case .invalid:
			return "INVALID"
		case .blocked:
			return "BLOCKED"
		}
	}
}

extension HealthCertificate {
	
	var dccWalletCertificate: DCCWalletCertificate {
		DCCWalletCertificate(
			barcodeData: base45,
			cose: DCCWalletCertificateCose(
				kid: keyIdentifier ?? ""
			),
			cwt: cborWebTokenHeader,
			hcert: digitalCovidCertificate,
			validityState: validityState.identifier
		)
	}
}
