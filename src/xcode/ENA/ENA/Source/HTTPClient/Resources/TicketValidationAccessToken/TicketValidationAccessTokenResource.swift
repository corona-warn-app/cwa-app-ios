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

	func customError(
		for error: ServiceError<TicketValidationAccessTokenError>,
		responseBody: Data? = nil
	) -> TicketValidationAccessTokenError? {
		switch error {
		case .trustEvaluationError(let trustEvaluationError):
			return trustEvaluationErrorHandling(trustEvaluationError)
		case .resourceError:
			return .ATR_PARSE_ERR
		case .transportationError:
			return .ATR_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			return unexpetedServerErrorHandling(statusCode)
		default:
			return nil
		}
	}

	// MARK: - Private

	private func trustEvaluationErrorHandling(
		_ trustEvaluationError: (TrustEvaluationError)
	) -> TicketValidationAccessTokenError? {
		switch trustEvaluationError {
		case .jsonWebKey(let jsonWebKeyTrustEvaluationError):
			switch jsonWebKeyTrustEvaluationError {
			case .CERT_PIN_MISMATCH:
				return .ATR_CERT_PIN_MISMATCH
			case .CERT_PIN_NO_JWK_FOR_KID:
				return .ATR_CERT_PIN_NO_JWK_FOR_KID
			default:
				return nil
			}
		default:
			return nil
		}
	}

	private func unexpetedServerErrorHandling(_ statusCode: (Int)) -> TicketValidationAccessTokenError? {
		switch statusCode {
		case (400...499):
			return .ATR_CLIENT_ERR
		case (500...599):
			return .ATR_SERVER_ERR
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
