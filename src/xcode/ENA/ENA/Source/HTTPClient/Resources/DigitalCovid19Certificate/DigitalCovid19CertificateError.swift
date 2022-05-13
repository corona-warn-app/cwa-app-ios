//
// 🦠 Corona-Warn-App
//

import Foundation

enum DigitalCovid19CertificateError: LocalizedError, Equatable {
    case unhandledResponse(Int)
    case dccPending
    case badRequest
    case tokenDoesNotExist
    case dccAlreadyCleanedUp
    case testResultNotYetReceived
    case internalServerError(reason: String?)
    case noNetworkConnection

	// MARK: - Protocol LocalizedError

	var errorDescription: String? {
		switch self {
		case .unhandledResponse(let code):
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(code))")
		case .dccPending:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgainDCCNotAvailableYet, "DCC_COMP_202")
		case .badRequest:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "DCC_COMP_400")
		case .tokenDoesNotExist:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_404")
		case .dccAlreadyCleanedUp:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.dccExpired, "DCC_COMP_410")
		case .testResultNotYetReceived:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_412")
		case .internalServerError(reason: let reason):
			switch reason {
			case "INTERNAL":
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500_INTERNAL")
			case "LAB_INVALID_RESPONSE":
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_LAB_INVALID_RESPONSE")
			case "SIGNING_CLIENT_ERROR":
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_SIGNING_CLIENT_ERROR")
			case "SIGNING_SERVER_ERROR":
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_SIGNING_SERVER_ERROR")
			case .some(let reason):
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500_\(reason)")
			case .none:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500")
			}
		case .noNetworkConnection:
			return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.noNetwork, "DGC_COMP_NO_NETWORK")
		}
	}

    // MARK: - Protocol Equatable

    static func == (lhs: DigitalCovid19CertificateError, rhs: DigitalCovid19CertificateError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }

}
