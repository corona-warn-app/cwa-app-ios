//
// 🦠 Corona-Warn-App
//

@testable import ENA
import class CertLogic.Rule

struct FakeRulesDownloadService: RulesDownloadServiceProviding {

	// MARK: - Init

	init(
		_ result: Result<[Rule], DCCDownloadRulesError>? = .success([Rule.fake(), Rule.fake(), Rule.fake()])
	) {
		self.result = result
	}

	// MARK: - Protocol RulesDownloadServiceProviding

	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], DCCDownloadRulesError>) -> Void
	) {
		completion(result ?? .failure(.NO_NETWORK))
	}

	// MARK: - Internal

	var result: Result<[Rule], DCCDownloadRulesError>?
}
