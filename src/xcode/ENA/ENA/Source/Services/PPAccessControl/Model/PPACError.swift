////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPACError: Error {
	case generationFailed
	case deviceNotSupported
	case timeIncorrect
	case timeUnverified
	case minimumTimeSinceOnboarding
	case submissionTooEarly

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
		case .minimumTimeSinceOnboarding:
			return "minimumTimeSinceOnboarding"
		case .submissionTooEarly:
			return "SUBMISSION_TOO_EARLY"

		}
	}
}
