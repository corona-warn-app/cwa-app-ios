////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension VaccinationEntry {

	var isLastDoseInASeries: Bool {
		doseNumber == totalSeriesOfDoses
	}

	var localVaccinationDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: dateOfVaccination)
	}

}
