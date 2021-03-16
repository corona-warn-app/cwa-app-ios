////
// 🦠 Corona-Warn-App
//

import Foundation

enum TraceWarningError: Error {
	case requestCreationError
	case defaultServerError(Error)
	case invalidResponseError(Int)
	case decodingJsonError(Int)
	case downloadError
}

extension TraceWarningError: Equatable {
	static func == (lhs: TraceWarningError, rhs: TraceWarningError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
