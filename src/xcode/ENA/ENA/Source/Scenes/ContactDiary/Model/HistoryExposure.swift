////
// 🦠 Corona-Warn-App
//

import Foundation

enum HistoryExposure: Equatable {
	case encounter(RiskLevel)
	case none
}
