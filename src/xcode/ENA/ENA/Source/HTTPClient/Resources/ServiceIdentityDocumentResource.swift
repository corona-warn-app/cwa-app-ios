//
// 🦠 Corona-Warn-App
//

import Foundation

struct ServiceIdentityDocumentResource: Resource {
	
	// MARK: - Init

	init() {
		self.locator = .appConfiguration
		self.type = .caching
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>()
	}
	
	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	
	typealias Receive = <#type#>
	
	typealias CustomError = Error
	
	
}
