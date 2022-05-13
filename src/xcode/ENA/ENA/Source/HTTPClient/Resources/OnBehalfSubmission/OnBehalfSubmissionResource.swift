//
// 🦠 Corona-Warn-App
//

import Foundation

enum OnBehalfSubmissionResourceError: Error, Equatable {
	case invalidPayloadOrHeaders
	case invalidTan
	case requestCouldNotBeBuilt
	case serverError(Int)
}

struct OnBehalfSubmissionResource: Resource {

	init(
		payload: SubmissionPayload,
		isFake: Bool = false,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .submitOnBehalf(payload: payload, isFake: isFake)
		self.type = .default
		self.receiveResource = EmptyReceiveResource()
		self.trustEvaluation = trustEvaluation
		
		self.sendResource = ProtobufSendResource(
			SAP_Internal_SubmissionPayload.with {
				$0.requestPadding = payload.exposureKeys.submissionPadding
				$0.checkIns = payload.checkins
				$0.consentToFederation = false
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

	func customError(for error: ServiceError<OnBehalfSubmissionResourceError>, responseBody: Data?) -> OnBehalfSubmissionResourceError? {
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
