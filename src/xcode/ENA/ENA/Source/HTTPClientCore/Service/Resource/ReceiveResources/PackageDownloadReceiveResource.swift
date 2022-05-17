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
		if let stringValue = headers.value(caseInsensitiveKey: "content-length"),
			  let contentSize = Int(stringValue),
			  contentSize <= 0 {
			Log.info("Successfully downloaded empty traceWarningPackage", log: .api)
			let payload = PackageDownloadResponse(package: nil)
			return .success(payload)
		}

		guard let data = data else {
			return .failure(.missingData)
		}
		guard let package = SAPDownloadedPackage(compressedData: data) else {
			return .failure(.packageCreation)
		}
		guard signatureVerifier.verify(package) else {
			return .failure(.signatureVerification)
		}
		
		let payload = PackageDownloadResponse(package: package)
		return .success(payload)
	}

	// MARK: - Private

	private let signatureVerifier: SignatureVerification

}
