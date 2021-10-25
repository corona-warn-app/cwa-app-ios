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
		self.receiveResource = JSONReceiveResource<GetRegistrationTokenResponse>()
		self.keyModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<KeyModel>
	typealias Receive = JSONReceiveResource<GetRegistrationTokenResponse>
	typealias CustomError = TeleTanError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<KeyModel>
	var receiveResource: JSONReceiveResource<GetRegistrationTokenResponse>

	func customStatusCodeError(statusCode: Int) -> TeleTanError? {
		switch (keyModel.keyType, statusCode) {
		case (.teleTan, 400):
			return .teleTanAlreadyUsed
		case (_, 400):
			return .qrAlreadyUsed
		default:
			return nil
		}
	}

	func customModelError(model: Receive.ReceiveModel) -> CustomError? {
		if model.registrationToken == nil {
			return .invalidResponse
		} else {
			return nil
		}
	}

	// MARK: - Private

	private let keyModel: KeyModel

}

enum TeleTanError: Error {
	case teleTanAlreadyUsed
	case qrAlreadyUsed
	case invalidResponse
}
