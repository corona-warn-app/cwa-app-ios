////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension DigitalGreenCertificate {

	var isLastDoseInASeries: Bool {
		vaccinationCertificates[0].isLastDoseInASeries
	}

}
