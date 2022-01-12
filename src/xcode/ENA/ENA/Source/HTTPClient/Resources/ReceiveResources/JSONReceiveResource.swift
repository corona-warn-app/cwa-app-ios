//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Concrete implementation of ReceiveResource for JSON objects.
When a service receives a http response with body, containing some data, we just decode the data to make some JSON file of it.
Returns different RessourceErrors when decoding fails.
*/
struct JSONReceiveResource<R>: ReceiveResource where R: Decodable {
	
	// MARK: - Protocol ReceiveResource
	
	typealias ReceiveModel = R
	
	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<R, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		do {
			let model = try decoder.decode(R.self, from: data)
			return .success(model)
		} catch let DecodingError.keyNotFound(key, context) {
			Log.debug("missing key: \(key.stringValue)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(DecodingError.keyNotFound(key, context)))
		} catch let DecodingError.valueNotFound(type, context) {
			Log.debug("Type not found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(DecodingError.valueNotFound(type, context)))
		} catch let DecodingError.typeMismatch(type, context) {
			Log.debug("Type mismatch found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(DecodingError.typeMismatch(type, context)))
		} catch let DecodingError.dataCorrupted(context) {
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(DecodingError.dataCorrupted(context)))
		} catch {
			Log.debug("Failed to parse JSON answer - unhandled error", log: .client)
			return .failure(.decoding(nil))
		}
	}
	
	// MARK: - Private
	
	private let decoder = JSONDecoder()
}
