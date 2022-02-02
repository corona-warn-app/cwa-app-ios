//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit
import class CertLogic.Rule

protocol RulesDownloadServiceProviding {
	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], DCCDownloadRulesError>) -> Void
	)
}

class RulesDownloadService: RulesDownloadServiceProviding {
	
	// MARK: - Init

	init (
		restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Protocol RulesDownloadServiceProviding

	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], DCCDownloadRulesError>) -> Void
	) {
		guard ruleType != .boosterNotification else {
			Log.error("invalid use for booster rules download")
			fatalError("invalid use for booster rules download")
		}

		let resource = DCCRulesResource(ruleType: ruleType)
		restServiceProvider.load(resource) { result in
			DispatchQueue.main.async {
				switch result {
				case let .success(validationRulesModel):
					completion(.success(validationRulesModel.rules))
				case let .failure(error):
					if case let .receivedResourceError(customError) = error {
						completion(.failure(customError))
					} else {
						Log.error("Unhandled error \(error.localizedDescription)", log: .vaccination)
						completion(.failure(.RULE_CLIENT_ERROR(ruleType)))
					}
				}
			}
		}
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding

}
