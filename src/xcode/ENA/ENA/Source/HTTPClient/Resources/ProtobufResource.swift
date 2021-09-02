//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufResource<P>: Resource where P: SwiftProtobuf.Message {

	// MARK: - Init

	init(
		_ locator: Locator,
		signatureVerifier: SignatureVerifier = SignatureVerifier(),
		cachingMode: ResourceCachingMode = .none
	) {
		self.locator = locator
		self.signatureVerifier = signatureVerifier
		self.cachingMode = cachingMode
	}

	// MARK: - Overrides

	// MARK: - Protocol Resource

	typealias Model = P

	var locator: Locator

	let cachingMode: ResourceCachingMode

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

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let signatureVerifier: SignatureVerifier
}
