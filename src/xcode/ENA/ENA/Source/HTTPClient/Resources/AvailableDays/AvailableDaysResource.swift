//
// 🦠 Corona-Warn-App
//

import Foundation

struct AvailableDaysResource: Resource {

	// MARK: - Init

	init(
		country: String,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .availableDays(country: country)
		self.sendResource = Send()
		self.receiveResource = Receive()
		self.trustEvaluation = trustEvaluation
		self.type = .default
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<[String]>
	typealias CustomError = Error

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<[String]>
	var trustEvaluation: TrustEvaluating

}
