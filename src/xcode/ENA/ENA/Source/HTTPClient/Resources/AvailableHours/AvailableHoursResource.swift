//
// 🦠 Corona-Warn-App
//

import Foundation

struct AvailableHoursResource: Resource {

	// MARK: - Init

	init(
		day: String,
		country: String,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .availableHours(day: day, country: country)
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

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success([]),
		willLoadResource: nil
	)
#endif

}
