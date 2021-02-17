////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPACError: Error {
	case generationFailed
	case deviceNotSupported
	case timeIncorrect
	case timeUnverified

	var description: String {
		switch self {
		case .generationFailed:
			return "deviceCheck Token generation failed"
		case .deviceNotSupported:
			return "deviceNotSupported"
		case .timeIncorrect:
			return "timeIncorrect"
		case .timeUnverified:
			return "timeUnverified"
		}
	}
}
