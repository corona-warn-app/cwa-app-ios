//
// 🦠 Corona-Warn-App
//

import Foundation

enum RegistrationTokenError: Error {
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
		sendModel: SendRegistrationTokenModel
	) {
		self.locator = .tanForExposureSubmit(registrationToken: sendModel.tokenString, isFake: isFake)
		self.type = .default
		self.sendResource = PaddingJSONSendResource<SendRegistrationTokenModel>(sendModel)
		self.receiveResource = JSONReceiveResource<SubmissionTANModel>()
		self.registrationTokenModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = PaddingJSONSendResource<SendRegistrationTokenModel>
	typealias Receive = JSONReceiveResource<SubmissionTANModel>
	typealias CustomError = RegistrationTokenError

	var locator: Locator
	var type: ServiceType
	var sendResource: PaddingJSONSendResource<SendRegistrationTokenModel>
	var receiveResource: JSONReceiveResource<SubmissionTANModel>
	
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

	let registrationTokenModel: SendRegistrationTokenModel
}
