////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPADataType {
	case userData(UserMetadata)
	case riskExposureMetadata(RiskExposureMetadata)
	case clientMetadata(ClientMetadata)
}
