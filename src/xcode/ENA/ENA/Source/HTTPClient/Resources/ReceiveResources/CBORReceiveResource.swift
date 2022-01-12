//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Protocol for a specific Model to decode from CBOR data. Should normally be implemented by the Model which shall be decoded, NOT the Resource.
*/
protocol CBORDecoding {
	init(decodeCBOR: Data) throws
}

/**
Concrete implementation of ReceiveResource for CBOR objects.
Because CBOR objects are always packed into a signed package, we need the SignatureVerifier to ensure the correctness of the package.
When a service receives a http response with body, containing some data, we just decode the cbor data to make a specific model.
Returns different RessourceErrors when decoding fails.
*/
struct CBORReceiveResource<R>: ReceiveResource where R: CBORDecoding {

	// MARK: - Init
	
	init(
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.signatureVerifier = signatureVerifier
	}

	// MARK: - Protocol ReceiveResource

	typealias ReceiveModel = R

	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<R, ResourceError> {
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
			let model = try R(decodeCBOR: package.bin)
			return Result.success(model)
		} catch {
			return Result.failure(.decoding(error))
		}
	}

	// MARK: - Private

	private let signatureVerifier: SignatureVerification

}
