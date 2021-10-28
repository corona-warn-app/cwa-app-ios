//
// 🦠 Corona-Warn-App
//

import Foundation

struct AppConfigurationResource: Resource {

	// MARK: - Init

	init() {
		self.locator = .appConfiguration
		self.type = .caching
		self.sendResource = EmptySendResource<Any>()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource<Any>
	typealias Receive = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource<Any>
	var receiveResource: ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>

}
