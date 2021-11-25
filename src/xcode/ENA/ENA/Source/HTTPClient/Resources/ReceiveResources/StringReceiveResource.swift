//
// 🦠 Corona-Warn-App
//

import Foundation

struct StringReceiveResource: ReceiveResource {
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = String
	
	func decode(_ data: Data?) -> Result<String, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}

		guard let string = String(data: data, encoding: .utf8) else {
			return .failure(.decoding)
		}

		return .success(string)
	}

}
