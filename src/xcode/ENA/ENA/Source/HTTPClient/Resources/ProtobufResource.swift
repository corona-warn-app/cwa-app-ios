//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

struct ProtobufResource<P>: HTTPResource where P: SwiftProtobuf.Message {

	init(
		resourceLocator: ResourceLocator,
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
		self.resourceLocator = resourceLocator
		self.signatureVerifier = signatureVerifier
	}

	typealias Model = P

	let resourceLocator: ResourceLocator

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

	private let signatureVerifier: SignatureVerifier
}
