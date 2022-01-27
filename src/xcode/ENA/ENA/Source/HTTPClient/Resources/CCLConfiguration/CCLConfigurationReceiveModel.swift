//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct CCLConfigurationReceiveModel: CBORDecodable, MetaDataProviding {
	
	// MARK: - Protocol CBORDecoding
	
	static func make(with data: Data) -> Result<Data, ModelDecodingError> {
		
	
//		switch CCLConfigurationAccess().extractCCLConfiguration(from: data) {
//		 case .success(let configurationData):
//			return .success(CCLConfigurationReceiveModel(with: configurationData)
//		 case .failure(let error):
//			return .failure(.CBOR_DECODING_CLLCONFIGURATION(error))
//
		// TODO call decode from HealthCertifiedToolkit
		return .failure(.CBOR_DECODING)
	}
	
	// MARK: - Protocol MetaDataProviding
	
	var metaData: MetaData = MetaData()

	// MARK: - Internal
	
	// Call only for init with fallback data or when decoding was successfull. Otherwise never call this explicit.
	init(someVar: Data ) {
		self.someVar = someVar
	}

	// TODO take real model
	let someVar: Data
}
