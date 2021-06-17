////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCErrors {
	
	enum RegistrationError: Error, Equatable {
		case badRequest
		case tokenNotAllowed
		case tokenDoesNotExist
		case tokenAlreadyAssigned
		case internalServerError
		case unhandledResponse(Int)
		case defaultServerError(Error)
		case urlCreationFailed
		case noNetworkConnection
		
		// MARK: - Protocol Equatable

		static func == (lhs: RegistrationError, rhs: RegistrationError) -> Bool {
			lhs.localizedDescription == rhs.localizedDescription
		}
	}
	
	enum DigitalCovid19CertificateError: Error, Equatable {
		case urlCreationFailed
		case unhandledResponse(Int)
		case jsonError
		case dccPending
		case badRequest
		case tokenDoesNotExist
		case dccAlreadyCleanedUp
		case testResultNotYetReceived
		case internalServerError(reason: String?)
		case defaultServerError(Error)
		case noNetworkConnection
		
		// MARK: - Protocol Equatable
		
		static func == (lhs: DCCErrors.DigitalCovid19CertificateError, rhs: DCCErrors.DigitalCovid19CertificateError) -> Bool {
			lhs.localizedDescription == rhs.localizedDescription
		}
	}
}
