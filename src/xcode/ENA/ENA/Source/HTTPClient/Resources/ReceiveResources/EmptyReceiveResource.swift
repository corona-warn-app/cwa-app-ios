//
// 🦠 Corona-Warn-App
//

import Foundation

struct EmptyReceiveResource<R>: ReceiveResource {
	
	// MARK: - Init
	
	init() {}
		
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = R
	
	func decode(_ data: Data?) -> Result<R?, ResourceError> {
		return .success(nil)
	}
}
