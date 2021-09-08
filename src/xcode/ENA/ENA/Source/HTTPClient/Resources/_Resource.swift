//
// 🦠 Corona-Warn-App
//

import Foundation

enum HTTP {
	enum Method: String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
		case patch = "PATCH"
	}
}

enum ResourceError: Error {
	case missingData
	case decoding
	case encoding
	case packageCreation
	case signatureVerification
	case notModified
}

enum ResourceType {
	case `default`
	case caching
	case wifiOnly
	case retrying
}


protocol Resource {
	// Model is type of the model
	associatedtype Model

	var locator: Locator { get }
	var type: ResourceType { get }

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]?) -> URLRequest
}

/// describes a resource
///
protocol ResponseResource: Resource {
	func decode(_ data: Data?) -> Result<Model, ResourceError>
}

protocol RequestResource: Resource {
	var model: Model? { get }
	func encode() -> Result<Data, ResourceError>
}

enum ResponseResources {
	static let appConfiguration = ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(.appConfiguration, .caching)
}
