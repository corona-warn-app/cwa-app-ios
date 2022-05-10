//
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceWarningDownloadResource: Resource {

	// MARK: - Init
	init(
		unencrypted: Bool,
		country: String,
		packageId: Int,
		isFake: Bool = false,
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .traceWarningPackageDownload(unencrypted: unencrypted, country: country, packageId: packageId, isFake: isFake)
		self.type = .default
		self.sendResource = EmptySendResource()
		self.receiveResource = PackageDownloadReceiveResource(signatureVerifier: signatureVerifier)
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = PackageDownloadReceiveResource
	typealias CustomError = TraceWarningError

	let locator: Locator
	let type: ServiceType
	let sendResource: Send
	let receiveResource: Receive
	let trustEvaluation: TrustEvaluating
	var retryingCount: Int = 3

	func customError(
		for error: ServiceError<CustomError>,
		responseBody: Data? = nil
	) -> CustomError? {
		switch error {

		case let .resourceError(resourceError):
			return handleResourceError(resourceError)
		default:
			return nil
		}
	}

	// MARK: - Private

	private func handleResourceError(_ error: ResourceError?) -> CustomError? {
		guard let error = error else {
			return nil
		}
		switch error {
		case .missingData, .packageCreation:
			return .invalidResponseError
		case .decoding:
			return .decodingJsonError
		default:
			return .invalidResponseError
		}
	}
	
}
