//
// 🦠 Corona-Warn-App
//
import Foundation

struct TestResultResource: Resource {

	// MARK: - Init
	init(
		isFake: Bool = false,
		sendModel: RegistrationTokenSendModel
	) {
		self.locator = .testResult(isFake: isFake)
		self.type = .default
		self.sendResource = JSONSendResource<RegistrationTokenSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<TestResultModel>()
		self.regTokenModel = sendModel
	}

	// MARK: - Protocol Resource
	typealias Send = JSONSendResource<RegistrationTokenSendModel>
	typealias Receive = JSONReceiveResource<TestResultModel>
	typealias CustomError = TestResultError

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<RegistrationTokenSendModel>
	var receiveResource: JSONReceiveResource<TestResultModel>

	func customStatusCodeError(statusCode: Int) -> TestResultError? {
		switch statusCode {
		case 400:
			return .qrDoesNotExist
		default:
			return nil
		}
	}

	// MARK: - Private
	private let regTokenModel: RegistrationTokenSendModel
}

enum TestResultError: Error {
	case qrDoesNotExist

	var errorDescription: String? {
		switch self {
		case .qrDoesNotExist:
			return AppStrings.ExposureSubmissionError.qrNotExist

		}
	}
}
