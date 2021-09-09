//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftProtobuf

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

	func decode(_ data: Data?) -> Result<R, ResourceError> {
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
