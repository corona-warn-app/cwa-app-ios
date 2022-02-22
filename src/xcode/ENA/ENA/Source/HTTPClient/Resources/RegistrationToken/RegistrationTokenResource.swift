//
// 🦠 Corona-Warn-App
//

import Foundation

enum RegistrationTokenError: LocalizedError {
	case regTokenNotExist

	var errorDescription: String? {
		switch self {
		case .regTokenNotExist:
			return AppStrings.ExposureSubmissionError.regTokenNotExist
		}
	}
}

struct RegistrationTokenResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		sendModel: RegistrationTokenSendModel
	) {
		self.locator = .registrationToken(isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<RegistrationTokenSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<RegistrationTokenReceiveModel>()
		self.registrationTokenModel = sendModel
		self.trustEvaluation = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHash
		)
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<RegistrationTokenSendModel>
	typealias Receive = JSONReceiveResource<RegistrationTokenReceiveModel>
	typealias CustomError = RegistrationTokenError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<RegistrationTokenSendModel>
	var receiveResource: JSONReceiveResource<RegistrationTokenReceiveModel>
	
	func customError(for error: ServiceError<RegistrationTokenError>) -> RegistrationTokenError? {
		switch error {
		case .unexpectedServerError(let statusCode):
			switch statusCode {
			case (400):
				return .regTokenNotExist
			default:
				return nil
			}
		default:
			return nil
		}
	}

	// MARK: - Internal

	let registrationTokenModel: RegistrationTokenSendModel
}
