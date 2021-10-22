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
		self.keyModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<KeyModel>
	typealias Receive = EmptyReceiveResource
	typealias CustomError = TeleTanError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<KeyModel>
	var receiveResource: EmptyReceiveResource

	func customError(statusCode: Int) -> TeleTanError? {
		switch (keyModel.keyType, statusCode) {
		case (.teleTan, 400):
			return .teleTanAlreadyUsed
		case (.qrCode, 400):
			return .teleTanAlreadyUsed
		default:
			return nil
		}
	}

	func map(serviceError: ServiceError) -> TeleTanError {
		guard case let .resourceError(resourceError) = serviceError,
		   case let .special(customError) = resourceError,
		   let tanError = customError as? TeleTanError else {
			   return .unknown
		}
		return tanError
	}

	// MARK: - Private

	private let keyModel: KeyModel

}

enum TeleTanError: Error {
	case teleTanAlreadyUsed
	case qrCodeisInvalid
	case unknown
}
