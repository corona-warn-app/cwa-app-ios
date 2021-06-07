////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension DigitalGreenCertificate {

	var isLastDoseInASeries: Bool {
		vaccinationCertificates?[safe: 0]?.isLastDoseInASeries ?? false
	}

}
