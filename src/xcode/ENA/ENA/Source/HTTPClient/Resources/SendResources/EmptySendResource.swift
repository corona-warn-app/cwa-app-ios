//
// 🦠 Corona-Warn-App
//

import Foundation

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
