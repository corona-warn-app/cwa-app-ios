////
// 🦠 Corona-Warn-App
//

enum PPACError: Error {
	case generationFailed
	case deviceNotSupported
	case timeIncorrect
	case timeUnverified
	case submissionTooEarly
	case minimumTimeSinceOnboarding
}

extension PPACError: ErrorCodeProviding {
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
		case .submissionTooEarly:
			return "SUBMISSION_TOO_EARLY"
		case .minimumTimeSinceOnboarding:
			return "TIME_SINCE_ONBOARDING_UNVERIFIED"
		}
	}
}

extension PPACError: SRSErrorAlertProviding {
	var srsErrorAlert: SRSErrorAlert? {
		switch self {
		case .generationFailed:
			return .tryAgainLater
		case .deviceNotSupported:
			return .deviceNotSupported
		case .timeIncorrect:
			return .changeDeviceTime
		case .timeUnverified:
			return .timeSinceOnboardingUnverified
		case .submissionTooEarly:
			return .submissionTooEarly
		case .minimumTimeSinceOnboarding:
			return .timeSinceOnboardingUnverified
		}
	}
}
