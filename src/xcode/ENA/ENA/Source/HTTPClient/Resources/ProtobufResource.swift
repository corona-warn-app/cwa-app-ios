//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufResource<P>: Resource where P: SwiftProtobuf.Message {

	// MARK: - Init

	init(
		_ locator: Locator,
		_ type: ResourceType,
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
		self.locator = locator
		self.type = type
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Overrides

	// MARK: - Protocol Resource

	typealias Model = P

	var locator: Locator
	var type: ResourceType

	func decode(_ data: Data?) -> Result<P, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		guard let package = SAPDownloadedPackage(compressedData: data) else {
			return .failure(.packageCreation)
		}
		guard signatureVerifier.verify(package) else {
			return .failure(.signatureVerification)
		}

		do {
			let model = try P(serializedData: package.bin)
			return Result.success(model)
		} catch {
			return Result.failure(.decoding)
		}
	}

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]? = nil) -> URLRequest {
		let endpointURL = locator.endpoint.url(environmentData)
		let url = locator.paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		locator.headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		customHeader?.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		return urlRequest
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let signatureVerifier: SignatureVerifier
}
