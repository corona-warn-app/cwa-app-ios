//
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCPublicKeyRegistrationError: LocalizedError, Equatable {

	case badRequest
	case tokenNotAllowed
	case tokenDoesNotExist
	case tokenAlreadyAssigned
	case internalServerError
	case unhandledResponse(Int)
	case noNetworkConnection

	// MARK: - Protocol LocalizedError

	var errorDescription: String? {
		switch self {
		case .badRequest:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "PKR_400")
		case .tokenNotAllowed:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "PKR_403")
		case .tokenDoesNotExist:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "PKR_404")
		case .tokenAlreadyAssigned:
			// Not returned to the user, next request is started automatically
			return nil
		case .internalServerError:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_500")
		case .unhandledResponse(let code):
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(code)")
		case .noNetworkConnection:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.noNetwork, "PKR_NO_NETWORK")
		}
	}

	// MARK: - Protocol Equatable

	static func == (lhs: DCCPublicKeyRegistrationError, rhs: DCCPublicKeyRegistrationError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}

}
