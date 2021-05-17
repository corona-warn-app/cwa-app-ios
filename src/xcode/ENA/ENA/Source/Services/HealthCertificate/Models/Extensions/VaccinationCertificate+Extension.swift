////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension VaccinationCertificate {

	var isEligibleForProofCertificate: Bool {
		doseNumber == totalSeriesOfDoses
	}

}
