//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit
import class CertLogic.Rule

protocol RulesDownloadServiceProviding {
	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
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
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		let resource = DCCRulesResource(ruleType: ruleType)
		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(validationRulesModel):
				completion(.success(validationRulesModel.rules))
			case let .failure(error):
				guard let customError = resource.customError(for: error) else {
					Log.error("Unhandled error \(error.localizedDescription)", log: .vaccination)
					return
				}
				completion(.failure(customError))
			}
		}
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding

}
