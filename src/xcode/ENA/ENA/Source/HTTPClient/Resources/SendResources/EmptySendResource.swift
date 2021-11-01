//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Dummy empty implementation of SendResource when we expect a http request without any body data. In this case, we can always return a success with nil Data because there is nothing to encode. The sendModel is ignored in this case.
Will always return .success.
*/
struct EmptySendResource: SendResource {

	// MARK: - Protocol ReceiveResource
	
	typealias SendModel = Void
	var sendModel: Void?
	
	func encode() -> Result<Data?, ResourceError> {
		return .success(nil)
	}
}
