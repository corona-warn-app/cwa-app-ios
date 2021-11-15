//
// 🦠 Corona-Warn-App
//

/**
A SendResource knows how to encode the concrete object, which is passed at initialization as the SendModel (for example an JSON Object or a constructed protbuf). This SendModel is send to the server in the http request as its body.
The resource only knows of which type SendModel is and implements the concrete encode function to get at the end Data to assign it to the http request body.
*/
protocol SendResource {
	associatedtype SendModel
	var sendModel: SendModel? { get }
	func encode() -> Result<Data?, ResourceError>
}
