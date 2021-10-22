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

	func customError(statusCode: Int) -> CustomError?
	func map(serviceError: ServiceError) -> CustomError
}

/**
The errors that can occur while handling resources
*/
enum ResourceError: Error, Equatable {
	case missingData
	case decoding
	case encoding
	case packageCreation
	case signatureVerification
	case notModified
	case undefined
	case special(Error)

	// MARK: - Protocol Equatable

	static func == (lhs: ResourceError, rhs: ResourceError) -> Bool {
		switch (lhs, rhs) {
		case (.missingData, .missingData):
			return true
		case (.missingData, _):
			return false

		case (.decoding, .decoding):
			return true
		case (.decoding, _):
			return false

		case (.encoding, .encoding):
			return true
		case (.encoding, _):
			return false

		case (.packageCreation, .packageCreation):
			return true
		case (.packageCreation, _):
			return false

		case (.signatureVerification, .signatureVerification):
			return true
		case (.signatureVerification, _):
			return false

		case (.notModified, .notModified):
			return true
		case (.notModified, _):
			return false
		case (.undefined, .undefined):
			return true
		case (.undefined, _):
			return false

		case let (.special(LInner), RInner):
			return LInner.localizedDescription == RInner.localizedDescription
		}
	}
}
