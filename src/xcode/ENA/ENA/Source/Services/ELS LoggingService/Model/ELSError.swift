////
// 🦠 Corona-Warn-App
//

import Foundation

enum ELSError: Error {
	
	case ppacError(PPACError)
	case otpError(OTPError)
	case couldNotReadLogfile(_ message: String? = nil)
}
