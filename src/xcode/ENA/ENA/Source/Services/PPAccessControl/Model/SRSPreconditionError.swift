//
// 🦠 Corona-Warn-App
//

enum SRSPreconditionError: Error {
	
	/// Precondition: the app was installed in less than 48h
	case insufficientAppUsageTime
	
	/// Precondition: there was already a key submission without a registered test in the last 3 months
	case positiveTestResultWasAlreadySubmittedWithin90Days
	
	var errorCode: String { self.description }
	
	var message: String {
		switch self {
		case .insufficientAppUsageTime:
			return String(
				format: AppStrings.ExposureSubmissionDispatch.SRSWarnOthersPreconditionAlert.insufficientAppUsageTimeMessage,
				errorCode
			)
		case  .positiveTestResultWasAlreadySubmittedWithin90Days:
			return String(
				format: AppStrings.ExposureSubmissionDispatch.SRSWarnOthersPreconditionAlert.positiveTestResultWasAlreadySubmittedWithin90DaysMessage,
				errorCode
			)
		}
	}
}

extension SRSPreconditionError: ErrorCodeProviding {
	var description: ErrorCodeProviding.ErrorCode {
		switch self {
		case .insufficientAppUsageTime:
			return "MIN_TIME_SINCE_ONBOARDING"
		case .positiveTestResultWasAlreadySubmittedWithin90Days:
			return "SUBMISSION_TOO_EARLY"
		}
	}
}
