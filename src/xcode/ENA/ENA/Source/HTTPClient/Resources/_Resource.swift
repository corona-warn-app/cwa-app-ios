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

protocol LocationResource {
	var locator: Locator { get }
	var type: ServiceType { get }
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
