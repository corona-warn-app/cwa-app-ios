//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct TicketValidationResultTokenResource: Resource {

	// MARK: - Init

	init(
		resultTokenServiceURL: URL,
		jwt: String,
		sendModel: TicketValidationResultTokenSendModel,
		trustEvaluation: TrustEvaluating
	) {
		self.locator = .ticketValidationResultToken(resultTokenServiceURL: resultTokenServiceURL, jwt: jwt)
		self.type = .default
		self.sendResource = JSONSendResource<TicketValidationResultTokenSendModel>(sendModel)
		self.receiveResource = StringReceiveResource<TicketValidationAccessTokenReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<TicketValidationResultTokenSendModel>
	var receiveResource: StringReceiveResource<TicketValidationAccessTokenReceiveModel>
	var retryingCount: Int?

	func customError(
		for error: ServiceError<TicketValidationResultTokenError>,
		responseBody: Data? = nil
	) -> TicketValidationResultTokenError? {
		switch error {
		case .trustEvaluationError(let trustEvaluationError):
			return trustEvaluationErrorHandling(trustEvaluationError)
		case .resourceError:
			return .RTR_PARSE_ERR
		case .transportationError:
			return .RTR_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400...499):
				return .RTR_CLIENT_ERR
			case (500...599):
				return .RTR_SERVER_ERR
			default:
				return nil
			}
		default:
			return nil
		}
	}

	// MARK: - Private

	private func trustEvaluationErrorHandling(
		_ trustEvaluationError: (TrustEvaluationError)
	) -> TicketValidationResultTokenError? {
		switch trustEvaluationError {
		case .jsonWebKey(let jsonWebKeyTrustEvaluationError):
			switch jsonWebKeyTrustEvaluationError {
			case .CERT_PIN_MISMATCH:
				return .RTR_CERT_PIN_MISMATCH
			case .CERT_PIN_HOST_MISMATCH:
				return .RTR_CERT_PIN_HOST_MISMATCH
			default:
				return nil
			}
		default:
			return nil
		}
	}
}

enum TicketValidationResultTokenError: LocalizedError {

	case RTR_CLIENT_ERR
	case RTR_NO_NETWORK
	case RTR_SERVER_ERR
	case RTR_CERT_PIN_MISMATCH
	case RTR_PARSE_ERR
	case RTR_CERT_PIN_HOST_MISMATCH
}
