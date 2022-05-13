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
		guard let package = SAPDownloadedPackage(compressedData: data) else {
			return .failure(.packageCreation)
		}
		guard signatureVerifier.verify(package) else {
			return .failure(.signatureVerification)
		}

		let etag = headers.value(caseInsensitiveKey: "ETag")
		let payload = PackageDownloadResponse(package: package, etag: etag)
		return .success(payload)
	}

	// MARK: - Private

	private let signatureVerifier: SignatureVerification

}
