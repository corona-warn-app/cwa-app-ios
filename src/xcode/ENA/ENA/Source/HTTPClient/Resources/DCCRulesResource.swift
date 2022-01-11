//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCRulesResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		ruleType: HealthCertificateValidationRuleType
	) {
		self.locator = .DCCRules(rulePath: ruleType.urlPath, isFake: isFake)
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ValidationRules>()
	}

	// MARK: - Overrides

	// MARK: - Protocol Resource

	typealias CustomError = Error

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationRules>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
}
