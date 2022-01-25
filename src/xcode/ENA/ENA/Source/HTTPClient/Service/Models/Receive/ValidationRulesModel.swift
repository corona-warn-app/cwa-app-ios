//
// 🦠 Corona-Warn-App
//

import Foundation

import HealthCertificateToolkit
import class CertLogic.Rule

struct ValidationRulesModel: CBORDecoding {

	// MARK: - Protocol CBORDecoding
	
	static func decode(_ data: Data) -> Result<ValidationRulesModel, ModelDecodingError> {
		switch ValidationRulesAccess().extractValidationRules(from: data) {
		case .success(let rules):
			return Result.success(ValidationRulesModel(rules: rules))
		case .failure(let error):
			return Result.failure(.CBOR_DECODING_VALIDATION_RULES(error))
		}
	}

	// MARK: - Internal

	let rules: [Rule]
	
	// MARK: - Private
	
	private init(rules: [Rule] ) {
		self.rules = rules
	}
}
