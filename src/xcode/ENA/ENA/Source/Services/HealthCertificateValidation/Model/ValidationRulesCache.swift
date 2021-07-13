////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.Rule

struct ValidationRulesCache: Codable {
	
	// MARK: - Internal
	
	let lastValidationRulesETag: String
	let validationRules: [Rule]
}
