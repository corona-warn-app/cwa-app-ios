//
// 🦠 Corona-Warn-App
//

/**
 A Resource is a composition of locator (where a resources can be found), service type to be used, data to send (sendResource) and data to receive (receiveResource).
 */
protocol Resource {
	associatedtype Send: SendResource
	associatedtype Receive: ReceiveResource
	associatedtype CustomError: Error
	
	var locator: Locator { get }
	var type: ServiceType { get }
	var sendResource: Send { get }
	var receiveResource: Receive { get }
	
	// Defines a default value for no network cases as the specific receive model (for resources like e.g. AppConfig, AllowList)
	var defaultModel: Receive.ReceiveModel? { get }

	// define the range of status codes when the default model will get used
	var defaultModelRange: [Int] { get }

	// flag to disable loading of resource
	var isDisabled: Bool { get }

	func useFallBack(_ statusCode: Int) -> Bool
	
	var trustEvaluation: TrustEvaluating { get }
	
	func customError(for error: ServiceError<CustomError>, responseBody: Data?) -> CustomError?
	
#if !RELEASE
	/// Used to define a default mock Resource to be returned by the resource if needed (e.g. UITests)
	/// Will only be used by `RestServiceProviderStub` if not provided with a different LoadResource see`load` function in `RestServiceProviderStub`
	var defaultMockLoadResource: LoadResource? { get }
#endif
}

// Custom error handling & caching support

extension Resource {

	// empty default model range
	var defaultModelRange: [Int] {
		[]
	}

	// empty default model
	var defaultModel: Receive.ReceiveModel? {
		nil
	}

	var isDisabled: Bool { false }

	// if no default model range is give we always is the default model
	func useFallBack(_ statusCode: Int) -> Bool {
		if defaultModelRange.isEmpty {
			return true
		}
		return defaultModelRange.contains(statusCode)
	}

	func customError(for error: ServiceError<CustomError>, responseBody: Data?) -> CustomError? {
		return nil
	}
}

/**
 The errors that can occur while handling resources
 */
enum ResourceError: Error {
	case missingData
	case decoding(ModelDecodingError)
	case encoding
	case packageCreation
	case signatureVerification
	case notModified
	case undefined
	case missingEtag
	case missingCache
}

#if !RELEASE
extension Resource {
	var defaultMockLoadResource: LoadResource? { nil }
}
#endif
