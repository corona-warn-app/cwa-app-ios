//
// 🦠 Corona-Warn-App
//

/**
A ReceiveResource knows how to decode the data of the http response body. At the end, we receive a concrete object (for example an JSON Object or a protbuf).
The resource only knows of which type ReceiveModel is and implements the concrete encode function to get at the end a concrete object of the http response body's data.
*/
protocol ReceiveResource {
	associatedtype ReceiveModel
	func decode(_ data: Data?) -> Result<ReceiveModel?, ResourceError>
}
