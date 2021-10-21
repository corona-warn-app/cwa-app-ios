//
// 🦠 Corona-Warn-App
//

/**
A Resource is a composition of locator (where a resources can be found), service type to be used, data to send (sendResource) and data to receive (receiveResource).
*/
protocol Resource {
	associatedtype Send: SendResource
	associatedtype Receive: ReceiveResource

	var locator: Locator { get }
	var type: ServiceType { get }

	var sendResource: Send { get }
	var receiveResource: Receive { get }
}

/**
The errors that can occur while handling resources
*/
enum ResourceError: Error {
	case missingData
	case decoding
	case encoding
	case packageCreation
	case signatureVerification
	case notModified
	case undefined
}
