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
	
}
