////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.Rule

@available(*, deprecated, message: "old client API")
struct ValidationRulesCache: Codable {
	
	// MARK: - Internal
	
	let lastValidationRulesETag: String
	let validationRules: [Rule]
}
