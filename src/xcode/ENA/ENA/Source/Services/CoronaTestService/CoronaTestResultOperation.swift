////
// 🦠 Corona-Warn-App
//

import Foundation

final class CoronaTestResultOperation: AsyncOperation {
	
	// MARK: - Init
	
	init(client: Client, registrationToken: String, completion: @escaping Client.TestResultHandler) {
		self.client = client
		self.registrationToken = registrationToken
		self.completion = completion
		super.init()
	}
	
	// MARK: - Overrides
	
	override func main() {
		client.getTestResult(forDevice: registrationToken, isFake: false) { [weak self] result in
			self?.completion(result)
			self?.finish()
		}
	}
	
	// MARK: - Private
	
	private let client: Client
	private let registrationToken: String
	private let completion: Client.TestResultHandler
}
