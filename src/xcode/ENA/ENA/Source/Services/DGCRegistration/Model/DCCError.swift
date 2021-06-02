////
// 🦠 Corona-Warn-App
//

import Foundation

enum DGCError {
	enum RegistrationError: Error {
		case badRequest
		case tokenNotAllowed
		case tokenDoesNotExist
		case tokenAlreadyAssigned
		case internalServerError
		case generalError
		case unhandledResponse(Int)
		case defaultServerError(Error)
		case urlCreationFailed
	}
	
	enum DigitalCovid19CertificateError: Error {
		case urlCreationFailed
		case unhandledResponse(Int)
		case jsonError
		case dccPending
		case badRequest
		case tokenDoesNotExist
		case dccAlreadyCleanedUp
		case testResultNotYetReceived
		case internalServerError
		case defaultServerError(Error)
	}
}

extension DGCError.DigitalCovid19CertificateError: Equatable {
	static func == (lhs: DGCError.DigitalCovid19CertificateError, rhs: DGCError.DigitalCovid19CertificateError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
