//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct CCLConfigurationReceiveModel: CBORDecodable, MetaDataProviding {

	// MARK: - Init

	init(
		_ cclConfigurations: [CCLConfiguration]
	) {
		self.cclConfigurations = cclConfigurations
	}
	
	// MARK: - Protocol CBORDecoding
	
	static func make(with data: Data) -> Result<CCLConfigurationReceiveModel, ModelDecodingError> {
		switch CCLConfigurationAccess().extractCCLConfiguration(from: data) {
		case .success(let cclConfigurations):
			return .success(CCLConfigurationReceiveModel(cclConfigurations))
		case .failure(let error):
			return .failure(.CBOR_DECODING_CLLCONFIGURATION(error))
		}
	}
	
	// MARK: - Protocol MetaDataProviding
	
	var metaData: MetaData = MetaData()

	// MARK: - Internal

	let cclConfigurations: [CCLConfiguration]

}
