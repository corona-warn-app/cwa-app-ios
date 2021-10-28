//
// 🦠 Corona-Warn-App
//

import Foundation

struct TeleTanResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: KeyModel
	) {
		self.locator = .registrationToken(isFake: isFake)
		self.type = .default
		self.sendResource = JSONSendResource<KeyModel>(sendModel)
		self.receiveResource = EmptyReceiveResource()
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<KeyModel>
	typealias Receive = EmptyReceiveResource

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<KeyModel>
	var receiveResource: EmptyReceiveResource

}
