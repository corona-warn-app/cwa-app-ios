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

/// describes a resource
///
protocol Resource {

	// Model is type of the model
	associatedtype Model

	var locator: Locator { get }
	var type: ResourceType { get }

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]?) -> URLRequest
	// this will usably be the body
	func decode(_ data: Data?) -> Result<Model, ResourceError>
//	func encode()
}

enum ResponseResources {
	static let appConfiguration = ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(.appConfiguration, .caching)
}
