////
// 🦠 Corona-Warn-App
//

import Foundation

enum ELSError: Error {
	case generalError
	// TODO: more!
}

extension ELSError: Equatable {
	static func == (lhs: ELSError, rhs: ELSError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
