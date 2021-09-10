//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Dummy empty implementation of SendResource when we expect a http request without any body data. In this case, we can always return a success with nil Data because there is nothing to encode. The sendModel is ignored in this case.
Will always return .success.
*/
struct EmptySendResource<S>: SendResource {

	// MARK: - Init
	
	init() {
		self.sendModel = nil
	}
		
	// MARK: - Protocol ReceiveResource
	
	typealias SendModel = S
	var sendModel: S?
	
	func encode() -> Result<Data?, ResourceError> {
		return .success(nil)
	}
}
