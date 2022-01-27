//
// 🦠 Corona-Warn-App
//

import Foundation

struct JSONSendResource<S>: SendResource where S: Encodable {
	
	// MARK: - Init
	
	init(
		_ sendModel: S? = nil
	) {
		self.sendModel = sendModel
	}
	
	// MARK: - Protocol ReceiveResource
	
	typealias SendModel = S
	var sendModel: S?
	
	func encode() -> Result<Data?, ResourceError> {
		guard let model = sendModel else {
			return .success(nil)
		}
		do {
			let data = try encoder.encode(model)
			return Result.success(data)
		} catch {
			return Result.failure(.encoding)
		}
	}

	// MARK: - Private
	
	private let encoder = JSONEncoder()

}
