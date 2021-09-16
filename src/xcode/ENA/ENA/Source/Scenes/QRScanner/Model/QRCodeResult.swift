//
// 🦠 Corona-Warn-App
//

import Foundation

enum QRCodeResult {
	case checkin(TraceLocation)
	case coronaTest(CoronaTestRegistrationInformation)
	case certificate(HealthCertifiedPerson, HealthCertificate)
}

enum QRCodeParserError: Error {
	case scanningError(QRScannerError)
	case checkinQrError(CheckinQRScannerError)
	case coronaTestQrError(QRScannerError)
	case certificateQrError(HealthCertificateServiceError)
}
