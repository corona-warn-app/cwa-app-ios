////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension VaccinationCertificate {

	var isLastDoseInASeries: Bool {
		doseNumber == totalSeriesOfDoses
	}

}
