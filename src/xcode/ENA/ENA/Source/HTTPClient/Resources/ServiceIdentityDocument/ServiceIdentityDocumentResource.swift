//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct ServiceIdentityDocumentResource: Resource {

	// MARK: - Init

	init(
		endpointUrl: URL,
		trustEvaluation: TrustEvaluating
	) {
		self.locator = Locator.serviceIdentityDocument(endpointUrl: endpointUrl)
		self.type = .default
		self.sendResource = EmptySendResource()
		self.receiveResource = JSONReceiveResource<TicketValidationServiceIdentityDocument>()
		self.trustEvaluation = trustEvaluation
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<TicketValidationServiceIdentityDocument>
	typealias CustomError = ServiceIdentityDocumentResourceError

	let trustEvaluation: TrustEvaluating
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<TicketValidationServiceIdentityDocument>
	var retryingCount: Int?

	func customError(
		for error: ServiceError<ServiceIdentityDocumentResourceError>,
		responseBody: Data? = nil
	) -> ServiceIdentityDocumentResourceError? {
		switch error {
		case .trustEvaluationError(let trustEvaluationError):
			return trustEvaluationErrorHandling(trustEvaluationError)
		case .resourceError:
			return .VS_ID_PARSE_ERR
		case .transportationError:
			return .VS_ID_NO_NETWORK
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400...499):
				return .VS_ID_CLIENT_ERR
			case (500...599):
				return .VS_ID_SERVER_ERR
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
	) -> ServiceIdentityDocumentResourceError? {
		switch trustEvaluationError {
		case .jsonWebKey(let jsonWebKeyTrustEvaluationError):
			switch jsonWebKeyTrustEvaluationError {
			case .CERT_PIN_MISMATCH:
				return .VS_ID_CERT_PIN_MISMATCH
			case .CERT_PIN_HOST_MISMATCH:
				return .VS_ID_CERT_PIN_HOST_MISMATCH
			default:
				return nil
			}
		default:
			return nil
		}
	}
}

enum ServiceIdentityDocumentResourceError: Error {
	case VS_ID_PARSE_ERR
	case VS_ID_NO_NETWORK
	case VS_ID_CLIENT_ERR
	case VS_ID_SERVER_ERR
	case VS_ID_CERT_PIN_MISMATCH
	case VS_ID_CERT_PIN_HOST_MISMATCH
}
