//
// 🦠 Corona-Warn-App
//

import Foundation

struct JSONResource<M: Decodable>: HTTPResource {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol HTTPResource

	typealias Model = M
	
	let resourceLocator: ResourceLocator
/*
	let resourceLocator: ResourceLocator = ResourceLocator(
		endpoint: .dataDonation,
		paths: URL(staticString: "http://"),
		method: .get,
		headers: ["Content-Type": "application/json"]
	)
*/
	func decode(_ data: Data?) -> Result<M, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		do {
			let model = try decoder.decode(M.self, from: data)
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
