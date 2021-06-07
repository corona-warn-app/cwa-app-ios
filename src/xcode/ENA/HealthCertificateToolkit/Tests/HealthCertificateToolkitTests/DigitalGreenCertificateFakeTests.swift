//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import HealthCertificateToolkit

class DigitalGreenCertificateFakeTests: XCTestCase {

    func test_When_makeFake_Then_CorrectFakeIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        let result = DigitalGreenCertificateFake.makeBase45Fake(
            from: testCertificate,
            and: testHeader
        )

        guard case .success(let base45) = result else {
            XCTFail("Success expected.")
            return
        }

        let extractResult = certificateAccess.extractDigitalGreenCertificate(from: base45)

        guard case .success(let certificate) = extractResult else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(certificate, testCertificate)
    }

    private lazy var testCertificate: DigitalGreenCertificate = {
        DigitalGreenCertificate(
            version: "1.0.0",
            name: Name(
                familyName: "Schmitt Mustermann",
                givenName: "Erika Dörte",
                standardizedFamilyName: "SCHMITT<MUSTERMANN",
                standardizedGivenName: "ERIKA<DOERTE"
            ),
            dateOfBirth: "1964-08-12",
            vaccinationCertificates: [
                VaccinationCertificate(
                    diseaseOrAgentTargeted: "840539006",
                    vaccineOrProphylaxis: "1119349007",
                    vaccineMedicinalProduct: "EU/1/20/1528",
                    marketingAuthorizationHolder: "ORG-100030215",
                    doseNumber: 2,
                    totalSeriesOfDoses: 2,
                    dateOfVaccination: "2021-02-02",
                    countryOfVaccination: "DE",
                    certificateIssuer: "Bundesministerium für Gesundheit",
                    uniqueCertificateIdentifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
                )
            ],
            testCertificates: nil
        )
    }()

    private lazy var testHeader: CBORWebTokenHeader = {
    CBORWebTokenHeader(
    issuer: "DE",
    issuedAt: 1619167131,
    expirationTime: 1622725423
    )
    }()
}
