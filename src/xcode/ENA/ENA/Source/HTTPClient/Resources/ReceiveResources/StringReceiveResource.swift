//
// 🦠 Corona-Warn-App
//

import Foundation

protocol StringDecodable {
	associatedtype Model
	static func make(with data: Data) -> Result<Model, ModelDecodingError>
}

struct StringReceiveResource<R>: ReceiveResource where R: StringDecodable {

	// MARK: - Protocol ReceiveResource

	typealias ReceiveModel = R

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<R, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		
		switch R.make(with: data) {
			
		case let .success(someModel):
			// We need that cast for the compiler.
			if let modelWithCache = someModel as? R {
				return .success(modelWithCache)
			} else {
				return .failure(.decoding(ModelDecodingError.STRING_DECODING))
			}

		case let .failure(error):
			return .failure(.decoding(error))
		}

	}

}
