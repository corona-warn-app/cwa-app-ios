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
			return "DEVICE_TOKEN_GENERATION_FAILED"
		case .deviceNotSupported:
			return "DEVICE_TOKEN_NOT_SUPPORTED"
		case .timeIncorrect:
			return "DEVICE_TIME_INCORRECT"
		case .timeUnverified:
			return "DEVICE_TIME_UNVERIFIED"
		case .minimumTimeSinceOnboarding:
			return "TIME_SINCE_ONBOARDING_UNVERIFIED"
		case .submissionTooEarly:
			return "SUBMISSION_TOO_EARLY"

		}
	}
}
