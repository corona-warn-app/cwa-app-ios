//
// 🦠 Corona-Warn-App
//

import Foundation

struct FetchHourResource: Resource {

	// MARK: - Init
	init(
		day: String,
		country: String,
		hour: Int,
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .diagnosisKeysHour(day: day, country: country, hour: hour)
		self.type = .wifiOnly
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

}
