////
// 🦠 Corona-Warn-App
//

import UIKit

enum ErrorLoggingStatus {
	case active
	case inactive
	
	var bottomViewHeight: CGFloat {
		switch self {
		case .active:
			return 376
		case .inactive:
			return 240
		}
	}
}
