//
// 🦠 Corona-Warn-App
//

import Foundation

enum QRCodeResult {
	case checkin(TraceLocation)
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
