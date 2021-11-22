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
		self.sendResource = JSONSendResource<SendRegistrationTokenModel>(sendModel)
		self.receiveResource = JSONReceiveResource<SubmissionTANModel>()
		self.registrationTokenModel = sendModel
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<SendRegistrationTokenModel>
	typealias Receive = JSONReceiveResource<SubmissionTANModel>
	typealias CustomError = RegistrationTokenError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<SendRegistrationTokenModel>
	var receiveResource: JSONReceiveResource<SubmissionTANModel>

	func customStatusCodeError(statusCode: Int) -> RegistrationTokenError? {
		switch statusCode {
		case (400):
			return .regTokenNotExist
		default:
			return nil
		}
	}

	// MARK: - Internal

	let registrationTokenModel: SendRegistrationTokenModel
}
