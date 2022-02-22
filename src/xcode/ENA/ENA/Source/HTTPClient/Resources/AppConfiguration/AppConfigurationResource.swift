//
// 🦠 Corona-Warn-App
//

import Foundation

struct AppConfigurationResource: Resource {

	// MARK: - Init

	init() {
		self.locator = .appConfiguration
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>()
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHash
		)
	}

	// MARK: - Protocol Resource

	let trustEvaluation: TrustEvaluating

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>
	typealias CustomError = Error // no custom error here at the moment

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: ProtobufReceiveResource<SAP_Internal_V2_ApplicationConfigurationIOS>

}
