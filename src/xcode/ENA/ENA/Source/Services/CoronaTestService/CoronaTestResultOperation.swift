////
// 🦠 Corona-Warn-App
//

import Foundation

final class CoronaTestResultOperation: AsyncOperation {
	
	typealias ResultHandler = (Result<TestResultResource.Receive.ReceiveModel, ServiceError<TestResultError>>) -> Void
	
	// MARK: - Init
	
	init(restService: RestServiceProviding, registrationToken: String, completion: @escaping ResultHandler) {
		self.restService = restService
		self.registrationToken = registrationToken
		self.completion = completion
		super.init()
	}
	
	// MARK: - Overrides
	
	override func main() {
		let sendModel = TestResultSendModel(registrationToken: registrationToken)
		let resource = TestResultResource(isFake: false, sendModel: sendModel)

		restService.load(resource) { [weak self] result in
			self?.completion(result)
			self?.finish()
		}
	}
	
	// MARK: - Private
	
	private let restService: RestServiceProviding
	private let registrationToken: String
	private let completion: ResultHandler
}
