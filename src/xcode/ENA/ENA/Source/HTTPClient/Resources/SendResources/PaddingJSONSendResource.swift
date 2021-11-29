//
// 🦠 Corona-Warn-App
//

import Foundation

struct PaddingJSONSendResource<S>: SendResource where S: Encodable & PaddingResource {
	
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
			var paddingModel = model
			paddingModel.requestPadding = model.paddingCount
			let data = try encoder.encode(paddingModel)
			return Result.success(data)
		} catch {
			return Result.failure(.encoding)
		}
	}

	// MARK: - Private
	
	private let encoder = JSONEncoder()

}
