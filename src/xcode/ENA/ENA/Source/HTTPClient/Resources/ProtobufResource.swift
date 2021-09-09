//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufResource<P>: RequestResource & ResponseResource where P: SwiftProtobuf.Message {

	// MARK: - Init

	init(
		_ locator: Locator,
		_ type: ServiceType,
		_ model: P? = nil,
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
		self.locator = locator
		self.type = type
		self.model = model
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Overrides

	// MARK: - Protocol ResponseResource

	typealias Model = P

	var locator: Locator
	var type: ServiceType

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]? = nil) -> Result<URLRequest, ResourceError> {
		let endpointURL = locator.endpoint.url(environmentData)
		let url = locator.paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		switch encode() {
		case let .success(data):
			urlRequest.httpBody = data
		case let .failure(error):
			return .failure(error)
		}

		locator.headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		customHeader?.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}
		return .success(urlRequest)
	}

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

	// MARK: - Protocol RequestResource

	var model: P?

	func encode() -> Result<Data?, ResourceError> {
		guard let model = model else {
			return .success(nil)
		}
		do {
			let data = try model.serializedData()
			return Result.success(data)
		} catch {
			return Result.failure(.encoding)
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let signatureVerifier: SignatureVerifier
}
