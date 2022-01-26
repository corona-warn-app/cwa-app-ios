//
// 🦠 Corona-Warn-App
//

import Foundation

struct CCLConfigurationReceiveModel: CBORDecoding {
	
	// MARK: - Protocol CBORDecoding
	
	static func decode(_ data: Data) -> Result<CCLConfiguration, ModelDecodingError> {
		return .failure(.CBOR_DECODING)
	}

	// MARK: - Internal

	let someVar: Data
	
	// MARK: - Private
	
	private init(someVar: Data ) {
		self.someVar = someVar
	}
}
