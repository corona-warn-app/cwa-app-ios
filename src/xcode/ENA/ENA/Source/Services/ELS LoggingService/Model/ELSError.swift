////
// 🦠 Corona-Warn-App
//

import Foundation

enum ELSError: Error {
	
	case ppacError(PPACError)
	case otpError(OTPError)
	case urlCreationError
	case responseError(Int)
	case jsonError
	case defaultServerError(Error)
	case emptyLogFile
	case couldNotReadLogfile(_ message: String? = nil)
	case restServiceError(ServiceError<SubmitELSResource.CustomError>)

}

extension ELSError: Equatable {
	static func == (lhs: ELSError, rhs: ELSError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
