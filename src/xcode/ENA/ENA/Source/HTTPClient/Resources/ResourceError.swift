//
// 🦠 Corona-Warn-App
//

/**
The errors that can occur while decoding or encoding the specific resource
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
