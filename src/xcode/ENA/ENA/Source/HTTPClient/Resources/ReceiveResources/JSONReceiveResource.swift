//
// 🦠 Corona-Warn-App
//

import Foundation

struct JSONReceiveResource<R>: ReceiveResource where R: Decodable {
	
	// MARK: - Init
	
	init() {}
	
	// MARK: - Overrides
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = R
	
	func decode(_ data: Data?) -> Result<R, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		do {
			let model = try decoder.decode(R.self, from: data)
			return .success(model)
		} catch let DecodingError.keyNotFound(key, context) {
			Log.debug("missing key: \(key.stringValue)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.valueNotFound(type, context) {
			Log.debug("Type not found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.typeMismatch(type, context) {
			Log.debug("Type mismatch found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.dataCorrupted(context) {
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch {
			Log.debug("Failed to parse JSON answer - unhandled error", log: .client)
		}
		return .failure(.decoding)
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let decoder = JSONDecoder()
}
