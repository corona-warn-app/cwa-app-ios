//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct TicketValidationAccessTokenResource: Resource {

	// MARK: - Init

	init(
		accessTokenServiceURL: URL,
		jwt: String,
		sendModel: TicketValidationAccessTokenSendModel,
		trustEvaluation: TrustEvaluating
	) {
		self.locator = .ticketValidationAccessToken(
			accessTokenServiceURL: accessTokenServiceURL,
			jwt: jwt
		)
		self.type = .default
		self.sendResource = JSONSendResource<TicketValidationAccessTokenSendModel>(sendModel)
		self.receiveResource = StringReceiveResource<TicketValidationAccessTokenReceiveModel>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<TicketValidationAccessTokenSendModel>
	var receiveResource: StringReceiveResource<TicketValidationAccessTokenReceiveModel>

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
			case (400...499):
				return .ATR_CLIENT_ERR
			case (500...599):
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
