//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import HealthCertificateToolkit

class LegacyTest: XCTestCase {

    func test_Extracting130CertificateFrom100Base45() {

        // Create a certificate with 1.0.0 format.
        let certificate = DigitalCovidCertificate100.fake(
            testEntries: [
                TestEntry100.fake(dateTimeOfTestResult: "2021-05-29T22:34:17.595Z")
            ]
        )
        let base45Result = DigitalCovidCertificateFake.makeBase45Fake(certificate: certificate, header: CBORWebTokenHeader.fake())

        guard case let .success(base45) = base45Result else {
            XCTFail("Success expected.")
            return
        }

        // Try to extract an 1.3.0 certificate from 1.0.0 base45.
        let extractResult = DigitalCovidCertificateAccess().extractDigitalCovidCertificate(from: base45)

        guard case .success = extractResult else {
            XCTFail("Success expected.")
            return
        }
    }
}
