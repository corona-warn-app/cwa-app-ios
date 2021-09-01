//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import HealthCertificateToolkit

class DigitalCovidCertificateWithHeaderTests: XCTestCase {

    func test_recentVaccinationCertificate() {
        let mostRecentVaccinationCert = DigitalCovidCertificateWithHeader.fake(
            header: CBORWebTokenHeader.fake(
                issuedAt: Date(timeIntervalSince1970: 1),
                expirationTime: Date.distantFuture
            ),
            certificate: DigitalCovidCertificate.fake(
                vaccinationEntries: [.fake(
                    dateOfVaccination: "2021-02-02"
                )]
            )
        )

        let certificates = [
            mostRecentVaccinationCert,
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    issuedAt: Date(timeIntervalSince1970: 0),
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    vaccinationEntries: [.fake(
                        dateOfVaccination: "2021-02-02"
                    )]
                )
            ),
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    vaccinationEntries: [.fake(
                        dateOfVaccination: "2021-02-01"
                    )]
                )
            )
        ]

        XCTAssertEqual(certificates.recentVaccinationCertificate, mostRecentVaccinationCert)
    }

    func test_recentRecoveryCertificate() {
        let mostRecentRecoveryCert = DigitalCovidCertificateWithHeader.fake(
            header: CBORWebTokenHeader.fake(
                issuedAt: Date(timeIntervalSince1970: 1),
                expirationTime: Date.distantFuture
            ),
            certificate: DigitalCovidCertificate.fake(
                recoveryEntries: [.fake(
                    dateOfFirstPositiveNAAResult: "2021-02-02"
                )]
            )
        )

        let certificates = [
            mostRecentRecoveryCert,
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    issuedAt: Date(timeIntervalSince1970: 0),
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    recoveryEntries: [.fake(
                        dateOfFirstPositiveNAAResult: "2021-02-02"
                    )]
                )
            ),
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    recoveryEntries: [.fake(
                        dateOfFirstPositiveNAAResult: "2021-02-01"
                    )]
                )
            )
        ]

        XCTAssertEqual(certificates.recentRecoveryCertificate, mostRecentRecoveryCert)
    }
}
