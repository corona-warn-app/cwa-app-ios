//
// 🦠 Corona-Warn-App
//

import Foundation

/* a special receive resource to wrap Protobuf data and etag in a
 package struct. This gets used later in key processing */

struct PackageDownloadReceiveResource: ReceiveResource {

	// MARK: - Init

	init(
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Protocol ReceiveResource

	typealias ReceiveModel = PackageDownloadResponse

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<ReceiveModel, ResourceError> {
		guard let data = data else {
			return .failure(.missingData)
		}
		let package = SAPDownloadedPackage(compressedData: data)
		let payload = PackageDownloadResponse(package: package)
		return .success(payload)
	}

	// MARK: - Private

	private let signatureVerifier: SignatureVerification

}
