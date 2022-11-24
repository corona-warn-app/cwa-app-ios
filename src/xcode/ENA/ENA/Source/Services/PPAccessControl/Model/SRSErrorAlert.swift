//
// 🦠 Corona-Warn-App
//

/// The type of SRS error alert, depending on a corresponding error
enum SRSErrorAlert: String, CaseIterable {
	case callHotline = "CALL_HOTLINE"
	case changeDeviceTime = "CHANGE_DEVICE_TIME"
	case deviceNotSupported = "DEVICE_NOT_SUPPORTED"
	case deviceNotTrusted = "DEVICE_NOT_TRUSTED"
	case noNetwork = "NO_NETWORK"
	case submissionTooEarly = "SUBMISSION_TOO_EARLY"
	case timeSinceOnboardingUnverified = "TIME_SINCE_ONBOARDING_UNVERIFIED"
	case tryAgainLater = "TRY_AGAIN_LATER"
	case tryAgainNextMonth = "TRY_AGAIN_NEXT_MONTH"
	
	// MARK: - Init
	
	init(error: SRSErrorAlertProviding) {
		self = error.srsErrorAlert ?? .callHotline
	}
	
	// MARK: - Internal

	var message: String {
		switch self {
		case .callHotline:
			return AppStrings.SRSErrorAlert.callHotline
		case .changeDeviceTime:
			return AppStrings.SRSErrorAlert.changeDeviceTime
		case .deviceNotSupported:
			return AppStrings.SRSErrorAlert.deviceNotSupported
		case .deviceNotTrusted:
			return AppStrings.SRSErrorAlert.deviceNotTrusted
		case .noNetwork:
			return AppStrings.SRSErrorAlert.noNetwork
		case .submissionTooEarly:
			return AppStrings.SRSErrorAlert.submissionTooEarly
		case .timeSinceOnboardingUnverified:
			return AppStrings.SRSErrorAlert.timeSinceOnboardingUnverified
		case .tryAgainLater:
			return AppStrings.SRSErrorAlert.tryAgainLater
		case .tryAgainNextMonth:
			return AppStrings.SRSErrorAlert.tryAgainNextMonth
		}
	}
}
