////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension DigitalGreenCertificate {

	var isEligibleForProofCertificate: Bool {
		vaccinationCertificates[0].isEligibleForProofCertificate
	}

}
