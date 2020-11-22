//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum DetectionMode: Equatable {
	case automatic
	case manual

	static let `default` = DetectionMode.manual
}

extension DetectionMode {
	static func fromBackgroundStatus(
		_ backgroundStatus: UIBackgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
	) -> DetectionMode {
		switch backgroundStatus {
		case .restricted, .denied:
			return .manual
		case .available:
			return .automatic
		default:
			return .manual
		}
	}
}
