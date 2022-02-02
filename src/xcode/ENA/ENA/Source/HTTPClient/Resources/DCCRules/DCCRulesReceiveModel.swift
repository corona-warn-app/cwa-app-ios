//
// 🦠 Corona-Warn-App
//

import Foundation

import HealthCertificateToolkit
import class CertLogic.Rule

struct DCCRulesReceiveModel: CBORDecodable, MetaDataProviding {

	// MARK: - Protocol CBORDecoding
	
	static func make(with data: Data) -> Result<DCCRulesReceiveModel, ModelDecodingError> {
		switch ValidationRulesAccess().extractValidationRules(from: data) {
		case .success(let rules):
			return .success(DCCRulesReceiveModel(rules: rules))
		case .failure(let error):
			return .failure(.CBOR_DECODING_VALIDATION_RULES(error))
		}
	}

	// MARK: - Internal

	var metaData: MetaData = MetaData()

	let rules: [Rule]
	
	// MARK: - Private
	
	private init(rules: [Rule] ) {
		self.rules = rules
	}
}
