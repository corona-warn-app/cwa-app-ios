//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Dummy empty implementation of ReceiveResource when we expect a http response without any body data. In this case, we can always return a success with nil Data because there is nothing to decode.
Will always return .success.
*/
struct EmptyReceiveResource: ReceiveResource {
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = Void

	func decode(_ data: Data?) -> Result<ReceiveModel, ResourceError> {
		return .success(())
	}
}
