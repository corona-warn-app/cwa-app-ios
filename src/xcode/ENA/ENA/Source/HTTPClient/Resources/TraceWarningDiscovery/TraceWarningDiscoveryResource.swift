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
	typealias CustomError = TraceWarningError

	let locator: Locator
	let type: ServiceType
	let sendResource: Send
	let receiveResource: Receive
	let trustEvaluation: TrustEvaluating

	// MARK: - Protocol Resource

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
