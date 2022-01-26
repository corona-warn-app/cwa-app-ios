//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct CCLConfigurationReceiveModel: CBORDecoding {
	
	// MARK: - Protocol CBORDecoding
	
	static func decode(_ data: Data) -> Result<CCLConfiguration, ModelDecodingError> {
		// TODO call decode from HealthCertifiedToolkit
		return .failure(.CBOR_DECODING)
	}

	// MARK: - Internal

	// TODO take real model
	let someVar: Data
	
	// MARK: - Private
	
	private init(someVar: Data ) {
		self.someVar = someVar
	}
}
