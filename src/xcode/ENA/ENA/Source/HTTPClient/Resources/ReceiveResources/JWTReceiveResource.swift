//
// 🦠 Corona-Warn-App
//

import Foundation

struct JWTReceiveResource: ReceiveResource {
	
	// MARK: - Protocol ReceiveResource

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<JWTWithHeadersModel, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}

		guard let string = String(data: data, encoding: .utf8) else {
			return .failure(.decoding)
		}

		return .success(JWTWithHeadersModel(jwt: string, headers: headers))
	}

}
