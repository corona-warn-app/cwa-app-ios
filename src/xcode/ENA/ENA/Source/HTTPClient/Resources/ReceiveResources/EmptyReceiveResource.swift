//
// 🦠 Corona-Warn-App
//

import Foundation

struct EmptyReceiveResource<R>: ReceiveResource {
	
	// MARK: - Init
	
	init() {}
	
	// MARK: - Overrides
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = R
	
	func decode(_ data: Data?) -> Result<R, ResourceError> {
		return .failure(.decoding)
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
}
