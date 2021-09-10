//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Dummy empty implementation of ReceiveResource when we expect a http response without any body data. In this case, we can always return a success with nil Data because there is nothing to decode.
Will always return .success.
*/
struct EmptyReceiveResource<R>: ReceiveResource {
	
	// MARK: - Init
	
	init() {}
		
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = R
	
	func decode(_ data: Data?) -> Result<R?, ResourceError> {
		return .success(nil)
	}
}
