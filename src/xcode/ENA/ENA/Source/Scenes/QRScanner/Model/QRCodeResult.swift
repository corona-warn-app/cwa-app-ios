//
// 🦠 Corona-Warn-App
//

import Foundation

/// The result of a qrScan is a TraceLocation for checkins or warnings on behalf, a corona test or a healthCertificate (as a touple of person and certificate)
enum QRCodeResult {
	case traceLocation(TraceLocation)
	case coronaTest(CoronaTestRegistrationInformation)
	case certificate(HealthCertifiedPerson, HealthCertificate)
}

enum QRCodeParserError: Error, Equatable {
	case scanningError(QRScannerError)
	case checkinQrError(CheckinQRScannerError)
	case coronaTestQrError(QRScannerError)
	case certificateQrError(HealthCertificateServiceError)
	
	// MARK: - Protocol Equatable
	
	static func == (lhs: QRCodeParserError, rhs: QRCodeParserError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
