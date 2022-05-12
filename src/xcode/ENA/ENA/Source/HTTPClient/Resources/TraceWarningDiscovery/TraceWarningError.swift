////
// 🦠 Corona-Warn-App
//

import Foundation

enum TraceWarningError: Error {
	case generalError
	case defaultServerError(Error)
	case requestCreationError
	case invalidResponseError
	case decodingJsonError
	case noEarliestRelevantPackage
	case downloadIsRunning
	case identicationError
	case verificationError
}

extension TraceWarningError: Equatable {
	static func == (lhs: TraceWarningError, rhs: TraceWarningError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
