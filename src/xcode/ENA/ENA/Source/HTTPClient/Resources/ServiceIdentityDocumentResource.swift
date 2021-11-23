//
// 🦠 Corona-Warn-App
//

import Foundation

enum ServiceIdentityDocumentResourceError: Error {
	case VS_ID_PARSE_ERR
	case VS_ID_NO_NETWORK
	case VS_ID_CLIENT_ERR
	case VS_ID_SERVER_ERR
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
}
