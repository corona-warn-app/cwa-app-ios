//
// 🦠 Corona-Warn-App
//

import Foundation

enum QRCodeResult {
	case traceLocation(TraceLocation)
	case coronaTest(CoronaTestRegistrationInformation)
	case certificate(CertificateResult)
	case ticketValidation(TicketValidationInitializationData)
}

struct CertificateResult {
	let restoredFromBin: Bool
	let person: HealthCertifiedPerson
	let certificate: HealthCertificate
}

enum QRCodeParserError: Error, Equatable {
	case scanningError(QRScannerError)
	case checkinQrError(CheckinQRScannerError)
	case certificateQrError(HealthCertificateServiceError.RegistrationError)
	case ticketValidation(TicketValidationQRScannerError)
	
	// MARK: - Protocol Equatable
	// swiftlint:disable pattern_matching_keywords
	static func == (lhs: QRCodeParserError, rhs: QRCodeParserError) -> Bool {
		switch (lhs, rhs) {
		case (.scanningError(let scanningErrorLhs), .scanningError(let scanningErrorRhs)):
			return scanningErrorLhs == scanningErrorRhs
		case (.checkinQrError(let checkinQrErrorLhs), .checkinQrError(let checkinQrErrorRhs)):
			return checkinQrErrorLhs == checkinQrErrorRhs
		case (.certificateQrError(let certificateQrErrorLhs), .certificateQrError(let certificateQrErrorRhs)):
			return certificateQrErrorLhs.localizedDescription == certificateQrErrorRhs.localizedDescription
		case (.ticketValidation(let ticketValidationLhs), .ticketValidation(let ticketValidationRhs)):
			return ticketValidationLhs == ticketValidationRhs
		default:
			return false
		}
	}
}
