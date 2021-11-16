//
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertificateValidityState: Int, Codable {
	case valid
	case expiringSoon
	case expired
	case invalid
	case blocked
}
