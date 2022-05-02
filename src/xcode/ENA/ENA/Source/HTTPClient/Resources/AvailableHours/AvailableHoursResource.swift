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
		self.type = .wifiOnly
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<[Int]>
	typealias CustomError = Error

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: JSONReceiveResource<[Int]>
	var trustEvaluation: TrustEvaluating

	// We accept 404 responses since this can happen in case there
	// have not been any new cases reported on that day.
	// We don't report this as an error to simplify things for the consumer.
	var defaultModelRange: [Int] {
		[404]
	}

	var defaultModel: [Int]? = []

#if !RELEASE
	var defaultMockLoadResource: LoadResource? = LoadResource(
		result: .success([]),
		willLoadResource: nil
	)
#endif

}
