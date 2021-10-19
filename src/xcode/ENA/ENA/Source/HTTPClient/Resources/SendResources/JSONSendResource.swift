//
// 🦠 Corona-Warn-App
//

import Foundation

struct JSONSendResource<S>: SendResource where S: Encodable & PaddingResource {
	
	// MARK: - Init
	
	init(
		_ sendModel: S? = nil
	) {
		self.sendModel = sendModel
	}
	
	// MARK: - Overrides
	
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
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let encoder = JSONEncoder()

	// MARK: - Helper methods for adding padding to the requests.

	/// This method recreates the request body with a padding that consists of a random string.
	/// The entire request body must not be bigger than `maxRequestPayloadSize`.
	/// Note that this method is _not_ used for the key submission step, as this needs a different handling.
	/// Please check `getSubmissionPadding()` for this case.
	private func getPaddedRequestBody(for originalBody: [String: String]) throws -> Data {
		// This is the maximum size of bytes the request body should have.
		let maxRequestPayloadSize = 250

		// Copying in order to not use inout parameters.
		var paddedBody = originalBody
		paddedBody["requestPadding"] = ""
		let paddedData = try JSONEncoder().encode(paddedBody)
		let paddingSize = maxRequestPayloadSize - paddedData.count
		let padding = String.getRandomString(of: max(0, paddingSize))
		paddedBody["requestPadding"] = padding
		return try JSONEncoder().encode(paddedBody)
	}

	/// This method recreates the request body of the submit keys request with a padding that fills up to resemble
	/// a request with 14 +`n` keys. Note that the `n`parameter is currently set to 0, but can change in the future
	/// when there will be support for 15 keys.
	private func getSubmissionPadding(for keys: [SAP_External_Exposurenotification_TemporaryExposureKey]) -> Data {
		// This parameter denotes how many keys 14 + n have to be padded.
		let n = 0
		let paddedKeysAmount = 14 + n - keys.count
		guard paddedKeysAmount > 0 else { return Data() }
		guard let data = (String.getRandomString(of: 28 * paddedKeysAmount)).data(using: .ascii) else { return Data() }
		return data
	}


}
