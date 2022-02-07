//
// 🦠 Corona-Warn-App
//

import Foundation

struct TeleTanResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: TeleTanSendModel
	) {
		self.locator = .registrationToken(isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<TeleTanSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<RegistrationTokenReceiveModel>()
		self.keyModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<TeleTanSendModel>
	typealias Receive = JSONReceiveResource<RegistrationTokenReceiveModel>
	typealias CustomError = TeleTanError

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<TeleTanSendModel>
	var receiveResource: JSONReceiveResource<RegistrationTokenReceiveModel>

	func customError(for error: ServiceError<TeleTanError>) -> TeleTanError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch (keyModel.keyType, statusCode) {
			case (.teleTan, 400):
				return .teleTanAlreadyUsed
			case (_, 400):
				return .qrAlreadyUsed
			default:
				return nil
			}
		default:
			return nil
		}
	}
	
	// MARK: - Private

	private let keyModel: TeleTanSendModel

}

enum TeleTanError: LocalizedError {
	case teleTanAlreadyUsed
	case qrAlreadyUsed

	var errorDescription: String? {
		switch self {
		case .qrAlreadyUsed:
			return AppStrings.ExposureSubmissionError.qrAlreadyUsed
		case .teleTanAlreadyUsed:
			return AppStrings.ExposureSubmissionError.teleTanAlreadyUsed
		}
	}
}
