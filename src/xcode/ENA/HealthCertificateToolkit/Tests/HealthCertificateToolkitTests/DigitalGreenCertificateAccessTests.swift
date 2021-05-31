//
// 🦠 Corona-Warn-App
//


import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

final class DigitalGreenCertificateAccessTests: XCTestCase {

    func test_When_DecodeVaccinationCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        
        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataVaccinationCertificate.input)

        if case .failure(let error) = result {
            print(error)
        }

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataVaccinationCertificate.certificate)
    }

    func test_When_DecodeTestCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()

        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataTestCertificate.input)

        if case .failure(let error) = result {
            print(error)
        }

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataTestCertificate.certificate)
    }

    func test_When_DecodeCertificateFails_Then_PrefixInvalidErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        // "%69 VDL2" == "Hello"
        let base45WithoutPrefix = "%69 VDL2"

        let result = certificateAccess.extractDigitalGreenCertificate(from: base45WithoutPrefix)

        guard case let .failure(error) = result else {
            XCTFail("Error expected.")
            return
        }

        guard case .HC_PREFIX_INVALID = error else {
            XCTFail("HC_PREFIX_INVALID expected.")
            return
        }
    }

    func test_When_DecodeCertificateFails_Then_Base45DecodingErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        let nonBase45WithPrefix = hcPrefix+"==="

        let result = certificateAccess.extractDigitalGreenCertificate(from: nonBase45WithPrefix)

        guard case let .failure(error) = result else {
            XCTFail("Error expected.")
            return
        }

        guard case .HC_BASE45_DECODING_FAILED = error else {
            XCTFail("HC_BASE45_DECODING_FAILED expected.")
            return
        }
    }

    func test_When_DecodeCertificateFails_Then_CompressionErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        // "%69 VDL2" == "Hello"
        let base45NoZip = hcPrefix+"%69 VDL2"

        let result = certificateAccess.extractDigitalGreenCertificate(from: base45NoZip)

        guard case let .failure(error) = result else {
            XCTFail("Error expected.")
            return
        }

        guard case .HC_ZLIB_DECOMPRESSION_FAILED = error else {
            XCTFail("HC_ZLIB_DECOMPRESSION_FAILED expected.")
            return
        }
    }

    func test_When_DecodeCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()

        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataForSchemaError.input)

        guard case let .failure(error) = result else {
            XCTFail("Error expected.")
            return
        }

        guard case .HC_JSON_SCHEMA_INVALID(let schemaError) = error else {
            XCTFail("HC_JSON_SCHEMA_INVALID expected.")
            return
        }

        guard case .VALIDATION_RESULT_FAILED(let innerSchemaErrors) = schemaError else {
            XCTFail("VALIDATION_RESULT_FAILED expected.")
            return
        }

        let containsNODateOfBirthError = innerSchemaErrors.contains {
            $0.description == "'NODateOfBirth' does not match pattern: '(19|20)\\d{2}-\\d{2}-\\d{2}'"
        }

        let containsNODateOfVaccination = innerSchemaErrors.contains {
            $0.description == "'NODateOfVaccination' does not match pattern: '(19|20)\\d{2}-\\d{2}-\\d{2}'"
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 50"
        }

        XCTAssertEqual(innerSchemaErrors.count, 3)
        XCTAssertTrue(containsNODateOfBirthError)
        XCTAssertTrue(containsNODateOfVaccination)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeSucceeds_Then_CorrectHeaderIsReturned() throws {
        let certificateAccess = DigitalGreenCertificateAccess()

        let result = certificateAccess.extractCBORWebTokenHeader(from: testDataVaccinationCertificate.input)

        guard case let .success(header) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(header, testDataVaccinationCertificate.header)
        let issuedAt = try XCTUnwrap(testDataVaccinationCertificate.header.issuedAt)
        XCTAssertGreaterThan(testDataVaccinationCertificate.header.expirationTime, issuedAt)
    }

    lazy var testDataVaccinationCertificate: TestData = {
        TestData (
            input: hcPrefix+"6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I",
            certificate: DigitalGreenCertificate(
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
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: 1619167131,
                expirationTime: 1622725423
            )
        )
    }()

    lazy var testDataTestCertificate: TestData = {
        TestData (
            input: hcPrefix+"NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH9+UIOOP-IP1SX5J4G5WVP%4CAT4V22F/8X*G3M9BM9Z0BFU2P4JY73JC3KD34LT7A3523*BBXSJ$IJGX8R/S+:KLD3JJ3.+IJYCDN0TA3RK37MBZD3K%IO1BT6HN%20YCS*KNS4Y6TLXKF85-Y3Q1JGOJEII9JJN9CJZIR9K5TSJZILDBZ8D%JTQOL0EC7KD/ZL/8D:8DQVDLED0AC2AU872Q.T:USMD37.ST+C*2T$/TVPTM*SQYDLADYR3.XI/VBVGTKOJQMI-ZJYIJQBB6R6LTMU0BR3UR:J.X0A%QEAKKGQAOI0QIRR97I2HOAXCK+-C1W4/GJI+C7*4M:KCY07LPMIH-O9XZQSH9R$FXQGDVBK*RZP3:*DG1W7SGT$7S%RMSG2UQYI95N923LDU2O3J$NNP5S29F DQ/HLTNP8EFNC3P:HDD8B1MM1M9NTNC30GH.Z8VHL+KLF%CD 810H.+8Z1HZD5CC9T0HSCO/20PMICZG5SPZ:NW38F5H7U9KF4%556$I1I2YQ8Z1R6CTN.C4 3EL52C6ZLFWX8CD6+2NTRUOHLC6P50SORRHXLI$R2NP%1G2AI.7OFLV$8QL4VA0F41J",
            certificate: DigitalGreenCertificate(
                version: "1.2.1",
                name: Name(
                    familyName: "Musterfrau-Gößinger",
                    givenName: "Gabriele",
                    standardizedFamilyName: "MUSTERFRAU<GOESSINGER",
                    standardizedGivenName: "GABRIELE"
                ),
                dateOfBirth: "1998-02-26",
                vaccinationCertificates: nil,
                testCertificates: [
                    TestCertificate(
                        diseaseOrAgentTargeted: "840539006",
                        typeOfTest: "LP217198-3",
                        testResult: "260415000",
                        naaTestName: nil,
                        ratTestName: "1232",
                        dateTimeOfSampleCollection: "2021-02-20T12:34:56Z",
//                        dateTimeOfTestResult: "2021-02-22T12:34:56+00:00",
                        testCenter: "Testing center Rödelheim 1",
                        countryOfTest: "DE",
                        certificateIssuer: "Bundesministerium für Gesundheit",
                        uniqueCertificateIdentifier: "01DE/84503/1119349007/DXZSHDGEURJF8ZFKIYIBK39A3#S"
                    )
                ]
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: 1619167131,
                expirationTime: 1622725423
            )
        )
    }()

    /// This data contains data which leads to validation errors.
    /// Schema validation errors:
    /// -Wrong format for dateOfBirth
    /// -Wrong format for dateOfVaccination
    /// -uniqueCertificateIdentifier length > 50
    lazy var testDataForSchemaError: TestData = {
        TestData (
            input: hcPrefix+"NCFOXN%TS3DH3ZSUZK+.V0ETD%65NL-AH6+UIOOP-IJFQ/Y68WAK*N%:QKD93B4:ZH6I1$4JN:IN1MKK9%OC*PP:+P*.1D9R+Q6646C%6RF6:X93O5RF6$T61R64IM64631A795*9VR3F.Q5O0VBJ14T9K6QTM90NPC9QPK9/1APEEPK9PYL.8V1:55/PYDPQ355/P3993CQ9:56755R56992Y9ZKQ899P8QX*9DB9G85XC1G:KX-QM2VCN5C-4A+2XEN QT QTHC31M3+E32R44$2%35Y.IE.KD+2H0D3ZCU7JI$24D0:M9A%N+892 7J235II3NJKMIZ J$XI4OIMEDTJCDIDGXE%DB.-B97U3-SY$NXNKD1D25CP9IPN3CIQ 52744E09AAO8%MQQK8+S4-R:KIIX0VJAMIH3HH$HF9NTYV4E1MZ3K1:HF.5E1MRB4LF9SEFI1MAKJREHV*5O6ND-IO*47*KB*KYQTHFTNS4.$S32TWZF.XI5VAWB2SKU+LR./GQ5OL-G56DAM5TQ0F0B.IFEZEC1I2.2DYUY13O6M$5D/H2RYE2ID99OP5RHQU1R3 H9X$CA14O4O83T WR16KPN8VN3D1E3H02AS6$J",
            certificate: DigitalGreenCertificate(
                version: "1.0.0",
                name: Name(
                    familyName: "Schmitt Mustermann",
                    givenName: "Erika Dörte",
                    standardizedFamilyName: "SCHMITT<MUSTERMANN",
                    standardizedGivenName: "ERIKA<DOERTE"
                ),
                dateOfBirth: "NODateOfBirth",
                vaccinationCertificates: [
                    VaccinationCertificate(
                        diseaseOrAgentTargeted: "SOMESTRING",
                        vaccineOrProphylaxis: "1119349007",
                        vaccineMedicinalProduct: "EU/1/20/1528",
                        marketingAuthorizationHolder: "ORG-100030215",
                        doseNumber: 2,
                        totalSeriesOfDoses: 2,
                        dateOfVaccination: "NODateOfVaccination",
                        countryOfVaccination: "DE",
                        certificateIssuer: "Bundesministerium für Gesundheit",
                        uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing e"
                    )
                ],
                testCertificates: nil
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: 1619167131,
                expirationTime: 1622725423
            )
        )
    }()
}

// MARK: - TestData

struct TestData {
    let input: String
    let certificate: DigitalGreenCertificate
    let header: CBORWebTokenHeader
}
