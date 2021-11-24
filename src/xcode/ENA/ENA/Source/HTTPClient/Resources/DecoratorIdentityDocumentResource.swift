//
// 🦠 Corona-Warn-App
//

import Foundation

struct DecoratorIdentityDocumentResource: Resource {

	// MARK: - Init

	init(url: URL, isFake: Bool = false) {
		self.locator = .identityDocumentDecorator(url: url)
		self.type = .default
		self.sendResource = EmptySendResource()
		self.receiveResource = JSONReceiveResource<ServiceIdentityDocument>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<ServiceIdentityDocument>
	typealias CustomError = DecoratorServiceIdentityDocumentError

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<ServiceIdentityDocument>
	
	func customError(for error: ServiceError<DecoratorServiceIdentityDocumentError>) -> DecoratorServiceIdentityDocumentError? {
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
		case .resourceError(.decoding):
			return .VD_ID_PARSE_ERR
		default:
			return nil
		}
	}
}
