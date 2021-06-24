////
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCValidationProgress {
	
	// MARK: - Internal

	var expirationCheck: Bool
	var jsonSchemaCheck: Bool
	var acceptanceRuleValidation: String?
	var invalidationRuleValidation: String?
}
