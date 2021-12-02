//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationResultTokenResource: Resource {

	// MARK: - Init

	init(
		resultTokenServiceURL: URL,
		jwt: String,
		sendModel: TicketValidationResultTokenSendModel
	) {
		self.locator = .ticketValidationResultToken(resultTokenServiceURL: resultTokenServiceURL, jwt: jwt)
		self.type = .dynamicPinning
		self.sendResource = JSONSendResource<TicketValidationResultTokenSendModel>(sendModel)
		self.receiveResource = StringReceiveResource()
	}

	// MARK: - Protocol Resource

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<TicketValidationResultTokenSendModel>
	var receiveResource: StringReceiveResource

	// swiftlint:disable cyclomatic_complexity
	func customError(for error: ServiceError<TicketValidationResultTokenError>) -> TicketValidationResultTokenError? {
		switch error {
		case .trustEvaluationError(let trustEvaluationError):
			switch trustEvaluationError {
			case .CERT_PIN_MISMATCH:
				return .RTR_CERT_PIN_MISMATCH
			case .CERT_PIN_NO_JWK_FOR_KID:
				return .RTR_CERT_PIN_NO_JWK_FOR_KID
			default:
				return nil
			}
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

}

enum TicketValidationResultTokenError: LocalizedError {

	case RTR_CLIENT_ERR
	case RTR_NO_NETWORK
	case RTR_SERVER_ERR
	case RTR_CERT_PIN_NO_JWK_FOR_KID
	case RTR_CERT_PIN_MISMATCH
	case RTR_PARSE_ERR

}
