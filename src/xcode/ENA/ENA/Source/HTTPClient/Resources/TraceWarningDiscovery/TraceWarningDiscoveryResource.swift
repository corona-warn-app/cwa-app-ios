//
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceWarningDiscoveryResource: Resource {

	// MARK: - Init
	init(
		unencrypted: Bool,
		country: String,
		isFake: Bool = false,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .traceWarningDiscovery(unencrypted: unencrypted, country: country, isFake: isFake)
		self.type = .default
		self.sendResource = EmptySendResource()
		self.receiveResource = JSONReceiveResource<TraceWarningDiscoveryModel>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = JSONReceiveResource<TraceWarningDiscoveryModel>
	typealias CustomError = Error

	let locator: Locator
	let type: ServiceType
	let sendResource: Send
	let receiveResource: Receive
	let trustEvaluation: TrustEvaluating

	// MARK: - Protocol Resource

	// MARK: - Internal

	// MARK: - Private

}
