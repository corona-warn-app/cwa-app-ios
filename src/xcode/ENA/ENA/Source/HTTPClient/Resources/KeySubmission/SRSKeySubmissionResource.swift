//
// 🦠 Corona-Warn-App
//

import Foundation

enum SRSKeySubmissionResourceError: LocalizedError, Equatable {
	case invalidPayloadOrHeader
	case invalidOtp
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
		self.receiveResource = EmptyReceiveResource()
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
	var receiveResource: EmptyReceiveResource

	func customError(for error: ServiceError<KeySubmissionResourceError>, responseBody: Data?) -> KeySubmissionResourceError? {
		switch error {
		case .invalidRequestError:
			return .requestCouldNotBeBuilt
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400:
				return .invalidPayloadOrHeaders
			case 403:
				return .invalidTan
			default:
				return .serverError(statusCode)
			}
		default:
			return nil
		}
	}
	
}
