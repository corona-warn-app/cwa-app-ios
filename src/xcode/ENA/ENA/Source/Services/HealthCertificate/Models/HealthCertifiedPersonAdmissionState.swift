//
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertifiedPersonAdmissionState {
	case twoGPlusPCR(twoG: HealthCertificate, pcrTest: HealthCertificate)
	case twoGPlusAntigen(twoG: HealthCertificate, antigenTest: HealthCertificate)
	case twoG
	case threeGWithPCR
	case threeGWithAntigen
	case other
}
