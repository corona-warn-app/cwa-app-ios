////
// 🦠 Corona-Warn-App
//

import Foundation

enum TraceWarningError: Error {
	case requestCreationError
	case defaultServerError(Error)
	case invalidResponseError(Int)
	case decodingJsonError(Int)
}
