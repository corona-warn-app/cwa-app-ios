////
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCValidationProgress {
	
	// MARK: - Internal

	let expirationCheck: Bool
	let jsonSchemaCheck: Bool
	let acceptanceRuleValidation: String?
	let invalidationRuleValidation: String?
}
