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
	
	// MARK: - Overrides
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case validationRules
		case lastValidationRulesETag
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		validationRules = try container.decode([Rule].self, forKey: .validationRules)
		lastValidationRulesETag = try container.decode(String.self, forKey: .lastValidationRulesETag)
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	let validationRules: [Rule]?
	let lastValidationRulesETag: String?
}
