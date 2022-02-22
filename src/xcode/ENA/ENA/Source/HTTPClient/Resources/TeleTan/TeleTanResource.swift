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
		self.locator = .teleTan(isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<TeleTanSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<TeleTanReceiveModel>()
		self.keyModel = sendModel
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHash
		)
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<TeleTanSendModel>
	typealias Receive = JSONReceiveResource<TeleTanReceiveModel>
	typealias CustomError = TeleTanError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<TeleTanSendModel>
	var receiveResource: JSONReceiveResource<TeleTanReceiveModel>

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
