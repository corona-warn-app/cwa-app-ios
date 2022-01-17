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
		_ result: Result<[Rule], HealthCertificateValidationError>?
	) {
		self.result = result
	}

	// MARK: - Protocol RulesDownloadServiceProviding

	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		completion(result ?? .failure(.RULES_VALIDATION_ERROR(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)))
	}

	// MARK: - Internal

	var result: Result<[Rule], HealthCertificateValidationError>?

}
