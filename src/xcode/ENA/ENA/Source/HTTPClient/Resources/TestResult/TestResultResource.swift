//
// 🦠 Corona-Warn-App
//
import Foundation

struct TestResultResource: Resource {

	// MARK: - Init
	init(
		isFake: Bool = false,
		sendModel: TestResultSendModel,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .testResult(isFake: isFake)
		self.type = .default
		self.sendResource = JSONSendResource<TestResultSendModel>(sendModel)
		self.receiveResource = JSONReceiveResource<TestResultReceiveModel>()
		self.regTokenModel = sendModel
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = JSONSendResource<TestResultSendModel>
	typealias Receive = JSONReceiveResource<TestResultReceiveModel>
	typealias CustomError = TestResultError

	let trustEvaluation: TrustEvaluating

	var locator: Locator
	var type: ServiceType
	var sendResource: JSONSendResource<TestResultSendModel>
	var receiveResource: JSONReceiveResource<TestResultReceiveModel>

	func customStatusCodeError(statusCode: Int) -> TestResultError? {
		switch statusCode {
		case 400:
			return .qrDoesNotExist
		default:
			return nil
		}
	}
	
#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success(TestResultReceiveModel(testResult: TestResult.negative.rawValue, sc: nil, labId: nil)),
		willLoadResource: nil
	)
#endif
	

	// MARK: - Private
	private let regTokenModel: TestResultSendModel
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
