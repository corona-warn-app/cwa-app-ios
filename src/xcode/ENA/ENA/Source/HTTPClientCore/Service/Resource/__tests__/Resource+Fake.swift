//
// 🦠 Corona-Warn-App
//

@testable import ENA

class ResourceFake: Resource {
	init(
		locator: Locator = .fake(),
		type: ServiceType = .caching(),
		sendResource: PaddingJSONSendResource<DummyResourceModel> = PaddingJSONSendResource<DummyResourceModel>(DummyResourceModel(dummyValue: "SomeValue", requestPadding: "")),
		receiveResource: JSONReceiveResource<DummyResourceModel> = JSONReceiveResource<DummyResourceModel>(),
		defaultModel: ResourceFake.Receive.ReceiveModel? = nil
	) {
		self.locator = locator
		self.type = type
		self.sendResource = sendResource
		self.receiveResource = receiveResource
		self.defaultModel = defaultModel
	}
	
	let locator: Locator
	let type: ServiceType
	let sendResource: PaddingJSONSendResource<DummyResourceModel>
	let receiveResource: JSONReceiveResource<DummyResourceModel>
	let defaultModel: ResourceFake.Receive.ReceiveModel?

	typealias Send = PaddingJSONSendResource<DummyResourceModel>
	typealias Receive = JSONReceiveResource<DummyResourceModel>
	typealias CustomError = Error

}

struct DummyResourceModel: PaddingResource, Codable, Equatable {
	var dummyValue: String
	var requestPadding: String = ""
}
