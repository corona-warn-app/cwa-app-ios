////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension VaccinationEntry {

	var isLastDoseInASeries: Bool {
		doseNumber == totalSeriesOfDoses
	}

}
