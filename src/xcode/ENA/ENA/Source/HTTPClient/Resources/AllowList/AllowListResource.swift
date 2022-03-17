//
// 🦠 Corona-Warn-App
//

import Foundation

struct AllowListResource: Resource {
	
	// MARK: - Init

	init(
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .allowList
		self.type = .caching(
			// define special cache policies to handle from the cache
			Set<CacheUsePolicy>([.noNetwork])
				.appendingStatusCodes(400...409)
				.appendingStatusCodes(500...509)
		)
		self.sendResource = EmptySendResource()
		self.receiveResource = ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>()
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>
	typealias CustomError = Error // no custom error here at the moment

	let trustEvaluation: TrustEvaluating
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: ProtobufReceiveResource<SAP_Internal_Dgc_ValidationServiceAllowlist>
	var retryingCount: Int?

	// Tech spec says that the default is an empty set
	var defaultModel: SAP_Internal_Dgc_ValidationServiceAllowlist? {
		return SAP_Internal_Dgc_ValidationServiceAllowlist()
	}
	
}
