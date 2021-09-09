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
	case undefined

}

enum ServiceType {
	case `default`
	case caching
	case wifiOnly
	case retrying
}


protocol ResourceDescribing {
	// Model is type of the model
	associatedtype Model

	var locator: Locator { get }
	var type: ServiceType { get }

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]?) -> Result<URLRequest, ResourceError>
}

/// describes a resource
///
protocol ResponseResource: ResourceDescribing {
	func decode(_ data: Data?) -> Result<Model, ResourceError>
}

protocol RequestResource: ResourceDescribing {
	var model: Model? { get }
	func encode() -> Result<Data?, ResourceError>
}


//enum Resources {
//	enum response {
//		static let appConfiguration = ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(.appConfiguration, .caching)
//	}
//
//	enum request {
//		static func appConfiguration(model: SAP_Internal_V2_ApplicationConfigurationIOS) -> ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS> {
//			return ProtobufResource<SAP_Internal_V2_ApplicationConfigurationIOS>(.appConfiguration, .caching, model)
//		}
//	}
//
//}

protocol LocationResource {

	var locator: Locator { get }
	var type: ServiceType { get }

	func urlRequest(environmentData: EnvironmentData, customHeader: [String: String]?) -> Result<URLRequest, ResourceError>
}

protocol SendResource {
	associatedtype SendModel
	var sendModel: SendModel? { get }
	func encode() -> Result<Data?, ResourceError>
}

protocol ReceiveResource {
	associatedtype ReceiveModel
	func decode(_ data: Data?) -> Result<ReceiveModel, ResourceError>
}
