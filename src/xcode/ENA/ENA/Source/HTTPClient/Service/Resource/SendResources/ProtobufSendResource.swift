//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufSendResource<S>: SendResource where S: SwiftProtobuf.Message {

	// MARK: - Init

	init(
		_ sendModel: S? = nil
	) {
		self.sendModel = sendModel
	}

	// MARK: - Protocol SendResource

	typealias SendModel = S
	var sendModel: S?

	func encode() -> Result<Data?, ResourceError> {
		guard let model = sendModel else {
			return .success(nil)
		}
		do {
			let data = try model.serializedData()
			return Result.success(data)
		} catch {
			return Result.failure(.encoding)
		}
	}

}
