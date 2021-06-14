//
// 🦠 Corona-Warn-App
//

import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

// swiftlint:disable line_length
final class DigitalGreenCertificateAccessTests: XCTestCase {

    func test_When_DecodeVaccinationCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataVaccinationCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataVaccinationCertificate.certificate)
    }

    func test_When_DecodeTestCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataTestCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataTestCertificate.certificate)
    }

    func test_When_DecodeRecoveryCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()
        let result = certificateAccess.extractDigitalGreenCertificate(from: testDataRecoveryCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataRecoveryCertificate.certificate)
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
        let nonBase45WithPrefix = hcPrefix + "==="

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
        let base45NoZip = hcPrefix + "%69 VDL2"

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

    func test_When_DecodeVaccinationCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfBirth
        /// -Wrong format for dateOfVaccination
        /// -uniqueCertificateIdentifier length > 50
        let fakeCertificate = DigitalGreenCertificate.fake(
            dateOfBirth: "NODateOfBirth",
            vaccinationEntries: [
                VaccinationEntry.fake(
                    dateOfVaccination: "NODateOfVaccination",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalGreenCertificateFake.makeBase45Fake(from: fakeCertificate, and: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalGreenCertificate(from: base45Fake)

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
            $0.description.contains("'NODateOfBirth' does not match pattern")
        }

        let containsNODateOfVaccination = innerSchemaErrors.contains {
            $0.description.contains("'NODateOfVaccination' does not match pattern")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 50"
        }

        XCTAssertEqual(innerSchemaErrors.count, 3)
        XCTAssertTrue(containsNODateOfBirthError)
        XCTAssertTrue(containsNODateOfVaccination)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeTestCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfBirth
        /// -Wrong format for dateTimeOfSampleCollection
        /// -Wrong format for dateTimeOfTestResult
        /// -uniqueCertificateIdentifier length > 50
        let fakeCertificate = DigitalGreenCertificate.fake(
            dateOfBirth: "NotADateOfBirth",
            testEntries: [
                TestEntry.fake(
                    dateTimeOfSampleCollection: "NotADateTimeOfSampleCollection",
                    dateTimeOfTestResult: "NotADateTimeOfTestResult",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalGreenCertificateFake.makeBase45Fake(from: fakeCertificate, and: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalGreenCertificate(from: base45Fake)

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

        let containsDateOfBirthError = innerSchemaErrors.contains {
            $0.description.contains("NotADateOfBirth' does not match pattern")
        }

        let containsDateTimeOfSampleCollectionError = innerSchemaErrors.contains {
            $0.description.contains("NotADateTimeOfSampleCollection' does not match pattern")
        }

        let containsDateTimeOfTestResult = innerSchemaErrors.contains {
            $0.description.contains("NotADateTimeOfTestResult' does not match pattern")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 50"
        }

        XCTAssertEqual(innerSchemaErrors.count, 4)
        XCTAssertTrue(containsDateOfBirthError)
        XCTAssertTrue(containsDateTimeOfSampleCollectionError)
        XCTAssertTrue(containsDateTimeOfTestResult)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeRecoveryCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalGreenCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfFirstPositiveNAAResult
        /// -uniqueCertificateIdentifier length > 50
        let fakeCertificate = DigitalGreenCertificate.fake(
            dateOfBirth: "NotADateOfBirth",
            recoveryEntries: [
                RecoveryEntry.fake(
                    dateOfFirstPositiveNAAResult: "NotADateOfFirstPositiveNAAResult",
                    certificateValidFrom: "NotACertificateValidFrom",
                    certificateValidUntil: "NotACertificateValidUntil",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalGreenCertificateFake.makeBase45Fake(from: fakeCertificate, and: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalGreenCertificate(from: base45Fake)

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

        let containsDateOfBirthError = innerSchemaErrors.contains {
            $0.description.contains("NotADateOfBirth' does not match pattern")
        }

        let containsDateOfFirstPositiveNAAResultError = innerSchemaErrors.contains {
            $0.description.contains("NotADateOfFirstPositiveNAAResult' is not a valid RFC 3339 formatted date.")
        }

        let containsCertificateValidFromError = innerSchemaErrors.contains {
            $0.description.contains("NotACertificateValidFrom' is not a valid RFC 3339 formatted date.")
        }

        let containsCertificateValidUntilError = innerSchemaErrors.contains {
            $0.description.contains("NotACertificateValidUntil' is not a valid RFC 3339 formatted date.")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 50"
        }

        XCTAssertEqual(innerSchemaErrors.count, 5)
        XCTAssertTrue(containsDateOfBirthError)
        XCTAssertTrue(containsDateOfFirstPositiveNAAResultError)
        XCTAssertTrue(containsCertificateValidFromError)
        XCTAssertTrue(containsCertificateValidUntilError)
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

    func test_When_DecryptAndComposeToWebToken_Then_CorrectWebTokenIsReturned() throws {
        let certificateAccess = DigitalGreenCertificateAccess()

        for encryptedTestData in encryptedTestDatas {
            let keyData = try XCTUnwrap(Data(base64Encoded: encryptedTestData.decryptedKey))
            let result = certificateAccess.decryptAndComposeToWebToken(from: encryptedTestData.input, dataEncryptionKey: keyData)

            guard case let .success(cborWebToken) = result else {
                XCTFail("Success expected.")
                return
            }
            let cborWebTokenData = Data(cborWebToken.encode())
            let cborWebTokenBase64 = cborWebTokenData.base64EncodedString()

            XCTAssertEqual(cborWebTokenBase64, encryptedTestData.output)
        }
    }

    func test_When_ConvertToBase45_And_ExtractCertificate_Then_SuccessIsReturned() throws {
        let certificateAccess = DigitalGreenCertificateAccess()

        for encryptedTestData in encryptedTestDatas {
            let keyData = try XCTUnwrap(Data(base64Encoded: encryptedTestData.decryptedKey))
            let result = certificateAccess.convertToBase45(from: encryptedTestData.input, with: keyData)

            guard case let .success(base45) = result else {
                XCTFail("Success expected.")
                return
            }

            let extractResult = certificateAccess.extractDigitalGreenCertificate(from: base45)

            guard case .success = extractResult else {
                XCTFail("Success expected.")
                return
            }
        }
    }

    private lazy var testDataVaccinationCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I",
            certificate: DigitalGreenCertificate(
                version: "1.0.0",
                name: Name(
                    familyName: "Schmitt Mustermann",
                    givenName: "Erika Dörte",
                    standardizedFamilyName: "SCHMITT<MUSTERMANN",
                    standardizedGivenName: "ERIKA<DOERTE"
                ),
                dateOfBirth: "1964-08-12",
                vaccinationEntries: [
                    VaccinationEntry(
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
                testEntries: nil,
                recoveryEntries: nil
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: 1619167131,
                expirationTime: 1622725423
            )
        )
    }()

    private lazy var testDataTestCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN%TSMAHN-HVN8J7UQMJ4/36 L-AHIT91RO4.S-OP %I83V8H9GJLUW5NW6SA3/-2E%5G%5TW5A 6YO6XL6Q3QR$P*NI92K*F2-8B0DJV1JD7U:CJX3CJ7J:ZJ83BTH2R638DJC0J*PIR8T3WS9.S*IJ5OI9YI:8DVFC%PD:NK8WCDAB2DNAHLW 70SO:GOLIROGO3T5ZXK9UO GOP*OSV8WP4K166K8A 6:-OGU6927CORX8Q6I4/$R/ER/ QXZOZZOWP4:/6F0P6HPE65V77ZJ82HPPEPHCRTWA+DPL*OCHP7IRZSP:WBW+QYQ6-B5B11XEDW33D8C. C290AQ5EPPQF67460R6646O59EB9:PE+.PTW5F$PI11UH97-5ZT5VZP0JEWYH:PIREGMCIGDB3LKDVAC7JLKB8UJ06JSVBDKBXEB0VL//ET2ADMG5JD*5ADK45TMN95ZTM+CSUHQN%A400H%UBT16Y5+Z9  38CRVS1I$6P+1VWU5:U2:UI36/8HTWU%/EYUUPWEBSHFKVHIM$AF5JRZ$FKCTYUD$PMYTF6%HJ29H/DA BT 36*N0FCZDRKWBGRINNNRAT94KZ5C95N38TBRJ*CF-7RBA1MOHQT1V472AV86O000*JCLCJ",
            certificate: DigitalGreenCertificate(
                version: "1.0.0",
                name: Name(
                    familyName: "Falorni",
                    givenName: "Sara",
                    standardizedFamilyName: "FALORNI",
                    standardizedGivenName: "SARA"
                ),
                dateOfBirth: "1987-04-22",
                vaccinationEntries: nil,
                testEntries: [
                    TestEntry(
                        diseaseOrAgentTargeted: "840539006",
                        typeOfTest: "LP6464-4",
                        testResult: "260415000",
                        naaTestName: "EUDCUVMXCMNIXU7OS5UBT0T8T",
                        ratTestName: "1242",
                        dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
                        dateTimeOfTestResult: "2021-05-31T08:58:17.595Z",
                        testCenter: "General Practitioner 3",
                        countryOfTest: "DE",
                        certificateIssuer: "Bundesministerium für Gesundheit",
                        uniqueCertificateIdentifier: "01DE/00000/1119349007/9QK4WRVMUOUIP7PYVNSFBK9GF"
                    )
                ],
                recoveryEntries: nil
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: 1619167131,
                expirationTime: 1622725423
            )
        )
    }()

    private lazy var testDataRecoveryCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN%TSMAHN-HVN8J7UQMJ4/36 L-AH+UC1RO4.S-OPT-I9QKUXI.I5HCF-+AF/8X*G-O9UVPQRHIY1VS1NQ1 WUQRELS4 CTHE7L4LXTC%*400THMVL%20YCZ/KD*S+*4KCTBYKGVV+TV F76AL**I$MV4$0ADF0NNNIV+*4.$S6ZC0JBW63MD34LT483F 2K%5PF5RBQ746B46O1N646EN95O5PF6846A$Q 76SW6SH932QXF7AC5ADNXMQ*Q6NY4 478L6IWM$S4O65YR60D4%IUOD4*EV3LCIS8DKD5C9PG9QVA0932QE+G9AXG/01%CMPK95%L//6JWE/.Q100R$FTM8*N9TL2A-FUTVC1OJ$5I5UH8T-0OG60NJOQ3T%80C6S23OS-5172W1CH$6:7Q5$VT6EY$NY+LV$2R3A1MMLHP2/L7O59SG6.2..TYUVNYT0G6-27$WBZP6NM13.60R3GSMF4ARSV*JO5PU.DGE39Y1GY8RN004GF 2",
            certificate: DigitalGreenCertificate(
                version: "1.0.0",
                name: Name(
                    familyName: "Martinelli",
                    givenName: "Amelia",
                    standardizedFamilyName: "MARTINELLI",
                    standardizedGivenName: "AMELIA"
                ),
                dateOfBirth: "1982-12-23",
                vaccinationEntries: nil,
                testEntries: nil,
                recoveryEntries: [
                    RecoveryEntry(
                        diseaseOrAgentTargeted: "840539006",
                        dateOfFirstPositiveNAAResult: "2021-05-22",
                        countryOfTest: "DE",
                        certificateIssuer: "Bundesministerium für Gesundheit",
                        certificateValidFrom: "2021-06-05",
                        certificateValidUntil: "2021-11-08",
                        uniqueCertificateIdentifier: "01DE/00000/1119349007/FMXDTGR7KMPPHS270PAK9MVDK"
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

    private lazy var encryptedTestDatas = [
        EncryptedTestData(
            input: "0oRNogEmBEiLxYhcyl5BXkBZAXBxvo73+06cLc73F5KIFuQdo7fLUnb7yF9QFtX9tIEmgSzHIXKbHcEiep5RTtb2UVS80vybmnwYa1k36HR2R2yTKGwvDWAUumw2ZjCnfp8CxKx3zQVRl6JrVdLiskWmo4qiK/EwyTHrw/5PZy4rd11vt9Y6wuZtlpOvFGDIDhGKpcgK93zfIQWY59xjxusr/4J3FCWpcy9YNehB6m4Az1NozXxOrL9DmFM38mWCkiHaPeWgedbqfKTg3x/vSrXSkXYnLpc6QHsRqW99r7yTXJffbK8X44KvgkUI9sIlVU5+2+IuwT4XBY2p/MLW4d9gfnAhZYTsn0nGuoj4KFHTo6fNkXsuZ6BWm5MurXR0dqiCd00B1ZKuTNV0QhdzaaB2pYtwBnxD65TW8D0VDrDDjZuYRzni032f5hgB7YDlvcWYWiv7o6T8DeCNAsJ0RdL/X1qe3bHvLOBvzF9XlTrg4vNF/3aeRn9libOf+0ufr5dEcVhA1NqKSb93S2El9dA0icVjK+DV4LbwVWajZmTmhqcsgzWhvl4/PmtAJ5/iT57FfoQvuOvlyhxRPgGSg33IuDnBCg==",
            output: "0oRNogEmBEiLxYhcyl5BXkBZAWGkAWtjd2EtYXBwLWNsaQQaYpdzwAYaYLZAQDkBA6EBpGN2ZXJlMS4wLjBjbmFtpGJnbmVFbGxlbmJmbmVDaGVuZ2NnbnRlRUxMRU5jZm50ZUNIRU5HY2RvYmoxOTY3LTA3LTE5YXSBq2J0Z2k4NDA1MzkwMDZidHRqTFAyMTcxOTgtM2JubXgZSVZDSUoxR1FaTTc4NzhFTE1VSU1BMDhER2JtYWQxMjQ0YnNjeBgyMDIxLTA1LTMxVDE2OjEzOjE2LjgzNlpiZHJ4GDIwMjEtMDYtMDFUMTQ6MTI6MTYuODM2WmJ0cmkyNjA0MTUwMDBidGNtVGVzdCBDZW50cmUgMWJjb2JERWJpc3ghQnVuZGVzbWluaXN0ZXJpdW0gZsO8ciBHZXN1bmRoZWl0YmNpeC8wMURFLzAwMDAwLzExMTkzNDkwMDcvRzdQU0JBWE1YVkEyTjBITTNVOFlWN1pNVFhA1NqKSb93S2El9dA0icVjK+DV4LbwVWajZmTmhqcsgzWhvl4/PmtAJ5/iT57FfoQvuOvlyhxRPgGSg33IuDnBCg==",
            decryptedKey: "/9o5eVNb9us5CsGD4F3J36Ju1enJ71Y6+FpVvScGWkE="
        ),
        EncryptedTestData(
            input: "0oRNogEmBEiLxYhcyl5BXkBZAXAN4hKvLEngs3MYcLe/cIyy0q0+0auk5A/Bme/WlymolXU8JSLJJcj3D7kwXCJoEOvsnU9P/IrVlTNF2fJBdWF6Oq22UzhyOPRuQiF7PvspbVzyeEo+H/PmtvbTZss6l/wLDoXPixjtCOaFn7Com6Z2pNQOZqkYGZzz4BanJfchoggM4HaH20H4AzANfMMqYa/rytHnz4BjlR82ZSOlg5e/Jbl78NRen6RkgLTwT3YSI1XV+gbLPK6Fhp5saqRmQgUQTTSO99Q/rdk6BG18RZxqw70zKb77ddxBzolgySbmRdUrpWdK9SvnsnivN3V1Auv5X18KpHO58SwyFoex7OUq73q6FAS9p+MdI2jh1e3LcwU12ZJaN56bRbTEAmT5MelZsYY+c6WWvcIND7tj3aDI5o8D9PyWZHPdz/uHn/Cesn7MgVEXvLQnfCVvuPkLDSGAGi47nRRmUoaN7+7GjPRYvTyrX5VWwnMK31QLADg9kFhAQ7d9IZ02KQ5OXt/fc3bpcombylOcXT2U+JXDwQadrFwHQdjeK1dw+RZM7UkD4l/TOQjO9B8JN13DlidhiqljGw==",
            output: "0oRNogEmBEiLxYhcyl5BXkBZAWukAWtjd2EtYXBwLWNsaQQaYpd0gAYaYLZBADkBA6EBpGN2ZXJlMS4wLjBjbmFtpGJnbmVCcmlhbmJmbmtDYWxhbWFuZHJlaWNnbnRlQlJJQU5jZm50a0NBTEFNQU5EUkVJY2RvYmoxOTk1LTA1LTIxYXSBq2J0Z2k4NDA1MzkwMDZidHRoTFA2NDY0LTRibm14GTFSVEg2Vk1JVThBTlFJQUNHNFNJS1REU0FibWFkMTMzMWJzY3gYMjAyMS0wNS0zMVQyMToyNDoyOC4yMTZaYmRyeBgyMDIxLTA2LTAxVDE0OjE1OjI4LjIxNlpidHJpMjYwNDE1MDAwYnRjbVRlc3QgQ2VudHJlIDFiY29iREViaXN4IUJ1bmRlc21pbmlzdGVyaXVtIGbDvHIgR2VzdW5kaGVpdGJjaXgvMDFERS8wMDAwMC8xMTE5MzQ5MDA3L1JMVTFBSlFSTlRPNlFaUlJUSjJENkpXWkhYQEO3fSGdNikOTl7f33N26XKJm8pTnF09lPiVw8EGnaxcB0HY3itXcPkWTO1JA+Jf0zkIzvQfCTddw5YnYYqpYxs=",
            decryptedKey: "RinMlpTdzQGw7kllamU9Pz6bTHEWVZi1Ocb4q8wfFSk="
        )
    ]
}
// swiftlint:enable line_length

// MARK: - TestData

private struct TestData {
    let input: String
    let certificate: DigitalGreenCertificate
    let header: CBORWebTokenHeader
}

private struct EncryptedTestData {
    let input: String
    let output: String
    let decryptedKey: String
}
