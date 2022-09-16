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
			return .failure(.decoding(.JSON_DECODING(DecodingError.keyNotFound(key, context))))
		} catch let DecodingError.valueNotFound(type, context) {
			Log.debug("Type not found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(.JSON_DECODING(DecodingError.valueNotFound(type, context))))
		} catch let DecodingError.typeMismatch(type, context) {
			Log.debug("Type mismatch found \(type)", log: .client)
			/*
			 In some cases like the OTP response for both ELS and EDUS we need a different
			 dateDecodingStrategy otherwise the decoding of the JSON response will fail, and since
			 we are using generics for the ReceiveResource there is no way to handle the Specific
			 case for OTP, then the best approach would be to try to decode with the expected
			 dateDecodingStrategy "i.e iso8601" if the default decoding fails,
			 if the second decoding fails we will return the error then.
			*/
			decoder.dateDecodingStrategy = .iso8601
			do {
				let model = try decoder.decode(R.self, from: data)
				return .success(model)
			} catch {
				Log.debug("Debug Description: \(context.debugDescription)", log: .client)
				return .failure(.decoding(.JSON_DECODING(DecodingError.typeMismatch(type, context))))
			}
		} catch let DecodingError.dataCorrupted(context) {
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
			return .failure(.decoding(.JSON_DECODING(DecodingError.dataCorrupted(context))))
		} catch {
			Log.debug("Failed to parse JSON answer - unhandled error", log: .client)
			return .failure(.decoding(.JSON_DECODING(error)))
		}
	}
	
	// MARK: - Private
	
	private let decoder = JSONDecoder()
}
