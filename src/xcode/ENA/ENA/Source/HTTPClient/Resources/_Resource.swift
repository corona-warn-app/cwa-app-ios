//
// 🦠 Corona-Warn-App
//

import Foundation

/**
A LocationResource describes where a resources can be found (Locator) and how to load it and so which service should be used (ServiceType)
*/
protocol LocationResource {
	var locator: Locator { get }
	var type: ServiceType { get }
}

/**
A SendResource knows how to encode the concrete object, which is passed at initialization as the SendModel (for example an JSON Object or a constructed protbuf). This SendModel is send to the server in the http request as its body.
The resource only knows of which type SendModel is and implements the concrete encode function to get at the end Data to assign it to the http request body.
*/
protocol SendResource {
	associatedtype SendModel
	var sendModel: SendModel? { get }
	func encode() -> Result<Data?, ResourceError>
}

/**
A ReceiveResource knows how to decode the data of the http response body. At the end, we receive a concrete object (for example an JSON Object or a protbuf).
The resource only knows of which type ReceiveModel is and implements the concrete encode function to get at the end a concrete object of the http response body's data.
*/
protocol ReceiveResource {
	associatedtype ReceiveModel
	func decode(_ data: Data?) -> Result<ReceiveModel?, ResourceError>
}
