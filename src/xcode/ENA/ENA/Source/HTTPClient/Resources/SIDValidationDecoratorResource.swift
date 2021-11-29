//
// 🦠 Corona-Warn-App
//

import Foundation

struct SIDValidationDecoratorResource: Resource {

	// MARK: - Init

	init(url: URL, isFake: Bool = false) {
		self.locator = .serviceIdentityDocumentValidationDecorator(url: url)
		self.type = .disabledPinning
		self.sendResource = EmptySendResource()
		self.receiveResource = JSONReceiveResource<TicketValidationServiceIdentityDocument>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<TicketValidationServiceIdentityDocument>
	typealias CustomError = ServiceIdentityResourceDecoratorError

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<TicketValidationServiceIdentityDocument>
	
	func customError(for error: ServiceError<ServiceIdentityResourceDecoratorError>) -> ServiceIdentityResourceDecoratorError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case 400...409:
				return .VD_ID_CLIENT_ERR
			case 500...509:
				return .VD_ID_SERVER_ERR
			default:
				return nil
			}
		case .transportationError(let transportationError):
			if let error = transportationError as NSError?,
			   error.domain == NSURLErrorDomain,
			   error.code == NSURLErrorNotConnectedToInternet {
				return .VD_ID_NO_NETWORK
			} else {
				return nil
			}
		case .resourceError(.decoding):
			return .VD_ID_PARSE_ERR
		default:
			return nil
		}
	}
}

enum ServiceIdentityResourceDecoratorError: Error {
	case VD_ID_CLIENT_ERR
	case VD_ID_NO_NETWORK
	case VD_ID_SERVER_ERR
	case VD_ID_PARSE_ERR
}
