//
// 🦠 Corona-Warn-App
//

import Foundation

enum SRSKeySubmissionResourceError: LocalizedError, Equatable {
	case invalidPayloadOrHeader
	case invalidOtp
	case tooManyRequestsKeyPerDay
	case requestCouldNotBeBuilt
	case serverError(Int)
	
	var errorDescription: String? {
		switch self {
		case let .serverError(code):
			return "\(AppStrings.ExposureSubmissionError.other)\(code) \(AppStrings.ExposureSubmissionError.otherend)"
		case .invalidPayloadOrHeader:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."
		case .invalidOtp:
			return "\(AppStrings.ExposureSubmissionDispatch.SRSSubmissionError.srsSubmissionInvalidOTP) - invalid OTP."
		case .tooManyRequestsKeyPerDay:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - The threshold of max SRS per day has reached."
		case .requestCouldNotBeBuilt:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."
		}
	}
}

struct SRSKeySubmissionResource: Resource {

	// MARK: - Init

	init(
		payload: SubmissionPayload,
		srsOtp: String,
		isFake: Bool = false,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .keySubmission(srsOtp: srsOtp, isFake: isFake)
		self.type = .default
		self.receiveResource = SRSSuccessReceiveResource()
		self.trustEvaluation = trustEvaluation
		
		self.sendResource = ProtobufSendResource(
			SAP_Internal_SubmissionPayload.with {
				$0.requestPadding = payload.exposureKeys.submissionPadding
				$0.keys = payload.exposureKeys
				$0.checkIns = payload.checkins
				// Consent needs always set to be false with SRS
				$0.consentToFederation = false
				$0.visitedCountries = payload.visitedCountries.map { $0.id }
				$0.submissionType = payload.submissionType
				$0.checkInProtectedReports = payload.checkinProtectedReports
			}
		)
	}
	
	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: ProtobufSendResource<SAP_Internal_SubmissionPayload>
	var receiveResource: SRSSuccessReceiveResource

	func customError(for error: ServiceError<SRSKeySubmissionResourceError>, responseBody: Data?) -> SRSKeySubmissionResourceError? {
		switch error {
		case .invalidRequestError:
			return .requestCouldNotBeBuilt
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400:
				return .invalidPayloadOrHeader
			case 403:
				return .invalidOtp
			case 429:
				return .tooManyRequestsKeyPerDay
			default:
				return .serverError(statusCode)
			}
		default:
			return nil
		}
	}
	
}
