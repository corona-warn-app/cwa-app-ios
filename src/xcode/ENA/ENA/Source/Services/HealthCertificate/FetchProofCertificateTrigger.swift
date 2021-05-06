////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

enum FetchProofCertificateTrigger {
	case automatic
	case manual
	case certificatesChanged
}
