//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationAccessTokenResource: Resource {

	// MARK: - Init

	init(
		accessTokenServiceURL: URL,
		jwt: String
	) {
		self.locator = .ticketValidationAccessToken(accessTokenServiceURL: accessTokenServiceURL, jwt: jwt)
		self.type = .dynamicPinning
		self.sendResource = JSONSendResource<TicketValidationAccessTokenModel>()
		self.receiveResource = JWTReceiveResource()
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<TicketValidationAccessTokenModel>
	typealias Receive = JWTReceiveResource
	typealias CustomError = TicketValidationAccessTokenError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<TicketValidationAccessTokenModel>
	var receiveResource: JWTReceiveResource

	// swiftlint:disable cyclomatic_complexity
	func customError(for error: ServiceError<TicketValidationAccessTokenError>) -> TicketValidationAccessTokenError? {
		switch error {
		case .trustEvaluationError(let trustEvaluationError):
			switch trustEvaluationError {
			case .CERT_PIN_MISMATCH:
				return .ATR_CERT_PIN_MISMATCH
			case .CERT_PIN_NO_JWK_FOR_KID:
				return .ATR_CERT_PIN_NO_JWK_FOR_KID
			default:
				return nil
			}
		case .resourceError:
			return .ATR_PARSE_ERR
		case .transportationError:
			return .ATR_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400...409):
				return .ATR_CLIENT_ERR
			case (500...509):
				return .ATR_SERVER_ERR
			default:
				return nil
			}
		default:
			return nil
		}
	}

}

enum TicketValidationAccessTokenError: LocalizedError {

	case ATR_CLIENT_ERR
	case ATR_NO_NETWORK
	case ATR_SERVER_ERR
	case ATR_CERT_PIN_NO_JWK_FOR_KID
	case ATR_CERT_PIN_MISMATCH
	case ATR_PARSE_ERR

}
