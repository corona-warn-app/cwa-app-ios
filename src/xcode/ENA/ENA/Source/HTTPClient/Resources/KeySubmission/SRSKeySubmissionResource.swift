//
// 🦠 Corona-Warn-App
//

import Foundation

enum SRSKeySubmissionResourceError: LocalizedError, Equatable {
	case invalidPayloadOrHeader
	case invalidOtp
	case tooManyKeyRequestsPerDay
	case requestCouldNotBeBuilt
	case serverError(Int)
	case clientError(Int)
	
	var errorDescription: String? {
		switch self {
		case let .serverError(code):
			return String(format: AppStrings.SRSErrorAlert.tryAgainLater, "\(SRSError.srsSUBServerError.description): \(code)")
		case let .clientError(code):
			return String(format: AppStrings.SRSErrorAlert.callHotline, "\(SRSError.srsSUBClientError.description): \(code)")
		case .invalidPayloadOrHeader:
			return String(format: AppStrings.SRSErrorAlert.callHotline, SRSError.srsSUB400.description)
		case .invalidOtp:
			return String(format: AppStrings.SRSErrorAlert.callHotline, SRSError.srsSUB403.description)
		case .tooManyKeyRequestsPerDay:
			return String(format: AppStrings.SRSErrorAlert.callHotline, SRSError.srsSUB429.description)
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
			// if the status code of the response is one of 400, 403, or 429, it shall fail with error code SRS_SUB_400, SRS_SUB_403, SRS_SUB_429 respectively
			case 400:
				return .invalidPayloadOrHeader
			case 403:
				return .invalidOtp
			case 429:
				return .tooManyKeyRequestsPerDay
			// if the status code is a different client error (400 to 499), it shall fail with error code SRS_SUB_CLIENT_ERROR
			case 400...499:
				return .clientError(statusCode)
			// if the status code is a server error (500 to 599), it shall fail with error code SRS_SUB_SERVER_ERROR
			case 500...599:
				return .serverError(statusCode)
			default:
				return .serverError(statusCode)
			}
		default:
			return nil
		}
	}
	
}
