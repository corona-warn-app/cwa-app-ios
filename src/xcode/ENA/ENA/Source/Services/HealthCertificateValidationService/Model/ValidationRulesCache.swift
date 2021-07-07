////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.Rule

struct ValidationRulesCache: Codable {
	
	// MARK: - Init
	
	init(
		validationRules: [Rule],
		lastValidationRulesETag: String
	) {
		self.validationRules = validationRules
		self.lastValidationRulesETag = lastValidationRulesETag
	}
	
	// MARK: - Internal
	
	let lastValidationRulesETag: String
	let validationRules: [Rule]
}
