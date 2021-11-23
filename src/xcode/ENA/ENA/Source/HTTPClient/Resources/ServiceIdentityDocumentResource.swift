//
// 🦠 Corona-Warn-App
//

import Foundation

enum ServiceIdentityDocumentResourceError: Error {
	case VS_ID_CLIENT_ERR
	case VS_ID_NO_NETWORK
	case VS_ID_SERVER_ERR
	case VS_ID_NO_ENC_KEY
	case VS_ID_NO_SIGN_KEY
	case VS_ID_CERT_PIN_NO_JWK_FOR_KID
	case VS_ID_CERT_PIN_MISMATCH
	case VS_ID_PARSE_ERR
	case VS_ID_EMPTY_X5C
}

struct ServiceIdentityDocumentResource: Resource {

	// MARK: - Init

	init(
		endpointUrl: URL
	) {
		self.locator = Locator.serviceIdentityDocument(endpointUrl: endpointUrl)
		self.type = .default
		self.sendResource = EmptySendResource()
		self.receiveResource = JSONReceiveResource<ServiceIdentityDocument>()
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<ServiceIdentityDocument>
	typealias CustomError = ServiceIdentityDocumentResourceError
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<ServiceIdentityDocument>
	
	func customError(for error: ServiceError<ServiceIdentityDocumentResourceError>) -> ServiceIdentityDocumentResourceError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400):
				return .VS_ID_NO_ENC_KEY
			default:
				return nil
			}
		default:
			return nil
		}
	}
}
