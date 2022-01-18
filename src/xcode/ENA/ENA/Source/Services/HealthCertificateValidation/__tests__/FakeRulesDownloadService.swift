//
// 🦠 Corona-Warn-App
//

@testable import ENA
import class CertLogic.Rule

struct FakeRulesDownloadService: RulesDownloadServiceProviding {

	// MARK: - Init

	static func dummyRulesResponse() -> [Rule] {
		[
			Rule.fake(),
			Rule.fake(),
			Rule.fake()
		]
	}

	init(
		_ result: Result<[Rule], DCCDownloadRulesError>?
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
