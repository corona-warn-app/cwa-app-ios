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

struct TicketValidationInitializationData: Codable {
	let `protocol`: String
	let protocolVersion: String
	let serviceIdentity: String
	let privacyUrl: String
	let token: String
	let consent: String
	let subject: String
	let serviceProvider: String
}

enum QRCodeParserError: Error, Equatable {
	case scanningError(QRScannerError)
	case checkinQrError(CheckinQRScannerError)
	case certificateQrError(HealthCertificateServiceError.RegistrationError)
	
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
		default:
			return false
		}
	}
}
