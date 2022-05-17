//
// 🦠 Corona-Warn-App
//

import Foundation

struct FetchDayResource: Resource {

	// MARK: - Init
	
	init(
		day: String,
		country: String,
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .diagnosisKeys(day: day, country: country)
		self.type = .default
		self.trustEvaluation = trustEvaluation
		self.sendResource = Send()
		self.receiveResource = PackageDownloadReceiveResource(signatureVerifier: signatureVerifier)
	}

	// MARK: - Protocol Resource

	typealias CustomError = Error

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: PackageDownloadReceiveResource
	var trustEvaluation: TrustEvaluating
	let retryingCount: Int = 3

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success(
			PackageDownloadResponse(
				package: SAPDownloadedPackage(
					keysBin: Data(),
					signature: Data()
				)
			)
		),
		willLoadResource: nil
	)
#endif

}
