//
// 🦠 Corona-Warn-App
//

import Foundation

import HealthCertificateToolkit
import class CertLogic.Rule

enum ModelDecodingError: Error {
	case STRING_DECODING
	case PROTOBUF_DECODING(Error)
	case JSON_DECODING(Error)
	case CBOR_DECODING

	case CBOR_DECODING_VALIDATION_RULES(RuleValidationError)
	case CBOR_DECODING_ONBOARDED_COUNTRIES(RuleValidationError)
}

struct ValidationRulesModel: CBORDecoding {

	static func decode(_ data: Data) -> Result<ValidationRulesModel, ModelDecodingError> {
		switch ValidationRulesAccess().extractValidationRules(from: data) {
		case .success(let rules):
			return Result.success(ValidationRulesModel(rules: rules))
		case .failure(let error):
			return Result.failure(.CBOR_DECODING_VALIDATION_RULES(error))
		}
	}

	private init(rules: [Rule] ) {
		self.rules = rules
	}

	// MARK: - Internal

	let rules: [Rule]

}
