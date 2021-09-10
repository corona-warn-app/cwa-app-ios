//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

/**
Concrete implementation of ReceiveResource for Protobuf objects.
Because Protofbuf objects are always packed into a signed package, we need the SignatureVerifier to ensure the correctness of the package.
When a service receives a http response with body, containing some data, we just decode the data to make some protobuf file of it.
Returns different RessourceErrors when decoding fails.
*/
struct ProtobufReceiveResource<R>: ReceiveResource where R: SwiftProtobuf.Message {

	// MARK: - Init
	
	init(
		signatureVerifier: SignatureVerifier = SignatureVerifier()
	) {
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Overrides

	// MARK: - Protocol ReceiveResource

	typealias ReceiveModel = R

	func decode(_ data: Data?) -> Result<R?, ResourceError> {
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
			let model = try R(serializedData: package.bin)
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
