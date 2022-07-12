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

	// Defines the trust evaluation for the certificate pinning.
	var trustEvaluation: TrustEvaluating { get }

	// Indicates if the loading of the resource should be retried. Counts descending.
	// NOTE: Compete logically with defaultModel: When setting both, we will first exhaust all retries and then when still failing we will return the defaultModel.
	var retryingCount: Int { get set }

	// resource identifier
	static var identifier: String { get }

	func customError(for error: ServiceError<CustomError>, responseBody: Data?) -> CustomError?
	
#if !RELEASE
	/// Used to define a default mock Resource to be returned by the resource if needed (e.g. UITests)
	/// Will only be used by `RestServiceProviderStub` if not provided with a different LoadResource see`load` function in `RestServiceProviderStub`
	var defaultMockLoadResource: LoadResource? { get }
#endif
}

// Standard values for every resource

extension Resource {

	// empty default model
	var defaultModel: Receive.ReceiveModel? {
		nil
	}

	// empty default model range
	var defaultModelRange: [Int] {
		[]
	}

	// Default implementation with empty setter to avoid implementing it in every resouce.
	var retryingCount: Int {
		get { 0 }
		// swiftlint:disable unused_setter_value
		set { }
	}

	// default implementation to create an identifier for resource
	static var identifier: String {
		return String(describing: self)
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
