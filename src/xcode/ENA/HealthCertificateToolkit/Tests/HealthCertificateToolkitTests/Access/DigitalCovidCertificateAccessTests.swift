//
// 🦠 Corona-Warn-App
//

import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

// swiftlint:disable line_length
final class DigitalCovidCertificateAccessTests: XCTestCase {

    func test_When_DecodeVaccinationCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()
        let result = certificateAccess.extractDigitalCovidCertificate(from: testDataVaccinationCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataVaccinationCertificate.certificate)
    }

    func test_When_DecodeVaccinationCertificateWithFloatExpirationDateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()
        let result = certificateAccess.extractDigitalCovidCertificate(from: testDataVaccinationCertificateWithFloatExpirationDate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataVaccinationCertificateWithFloatExpirationDate.certificate)
    }

    func test_When_DecodeTestCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()
        let result = certificateAccess.extractDigitalCovidCertificate(from: testDataTestCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataTestCertificate.certificate)
    }

    func test_When_DecodeRecoveryCertificateSucceeds_Then_CorrectCertificateIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()
        let result = certificateAccess.extractDigitalCovidCertificate(from: testDataRecoveryCertificate.input)

        guard case let .success(healthCertificate) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(healthCertificate, testDataRecoveryCertificate.certificate)
    }

    func test_When_DecodeCertificateFails_Then_PrefixInvalidErrorIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()
        // "%69 VDL2" == "Hello"
        let base45WithoutPrefix = "%69 VDL2"

        let result = certificateAccess.extractDigitalCovidCertificate(from: base45WithoutPrefix)

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
        let certificateAccess = DigitalCovidCertificateAccess()
        let nonBase45WithPrefix = hcPrefix + "==="

        let result = certificateAccess.extractDigitalCovidCertificate(from: nonBase45WithPrefix)

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
        let certificateAccess = DigitalCovidCertificateAccess()
        // "%69 VDL2" == "Hello"
        let base45NoZip = hcPrefix + "%69 VDL2"

        let result = certificateAccess.extractDigitalCovidCertificate(from: base45NoZip)

        guard case let .failure(error) = result else {
            XCTFail("Error expected.")
            return
        }

        guard case .HC_ZLIB_DECOMPRESSION_FAILED = error else {
            XCTFail("HC_ZLIB_DECOMPRESSION_FAILED expected.")
            return
        }
    }

    func test_When_DecodeSucceeds_Then_CorrectHeaderIsReturned() throws {
        let certificateAccess = DigitalCovidCertificateAccess()

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
        let certificateAccess = DigitalCovidCertificateAccess()

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
        let certificateAccess = DigitalCovidCertificateAccess()

        for encryptedTestData in encryptedTestDatas {
            let keyData = try XCTUnwrap(Data(base64Encoded: encryptedTestData.decryptedKey))
            let result = certificateAccess.convertToBase45(from: encryptedTestData.input, with: keyData)

            guard case let .success(base45) = result else {
                XCTFail("Success expected.")
                return
            }

            let extractResult = certificateAccess.extractDigitalCovidCertificate(from: base45)

            guard case .success = extractResult else {
                XCTFail("Success expected.")
                return
            }
        }
    }

    func test_When_ExtractKeyIdentifier_Then_SuccessIsReturned() {
        for keyIdentifierTestData in keyIdentifierTestDatas {
            let base45 = keyIdentifierTestData.input
            let expectedKeyIdentifier = keyIdentifierTestData.output

            let certificateAccess = DigitalCovidCertificateAccess()
            let keyIdentifierResult = certificateAccess.extractKeyIdentifier(from: base45)
            guard case let .success(keyIdentifier) = keyIdentifierResult else {
                XCTFail("Success expected.")
                return
            }
            XCTAssertEqual(keyIdentifier, expectedKeyIdentifier)
        }
    }

    private lazy var testDataVaccinationCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I",
            certificate: DigitalCovidCertificate(
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
                issuedAt: Date(timeIntervalSince1970: 1619167131),
                expirationTime: Date(timeIntervalSince1970: 1622725423)
            )
        )
    }()

    private lazy var testDataVaccinationCertificateWithFloatExpirationDate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN*TS0BI$ZD8UHRTHZDE+VJG$L20I7*S1RO4.SOTPA RK4T6KIGGJQEW5B9$WFKY7-MPW$NLEENKE$JDVPLW1KD0KSKE MCAOIC.UMV60$J7RMU%O8%MOT6T*Q5PIQ*NC.UXLI83GU8Q%3AA%SX64TJP-65IVQ4A7E:7LYPPTQ6W94EOPCRXS40 LHZA0D9E2LBHHGKLO-K%FGLIA5D8MJKQJK6HMMBI62K+PB/VSQOL9DLSWCZ3EBKDVIJ7UJQWT.+S1QDC8CK8CQ8C7:D9ZIHAPFVA.QOZXI$MI1VCSWC%PDDZ0JW6/979KTN$K.SS$FKGS4TNC-*NIRICVELZUZM9EN9-O9WLI2P5AT15 B3:UN58N/3H.JEHGKUN BGH7LKZKT8BH7L9EKUFF*FN  CXFNBEBAP83G0TTR3LQWXPS:5.DTWQEH:L+1O17ITHJHIN73S09T8FN15AA0S1JH6JC9ZFI%FX299S1COFBIE6.OJMS*QDIEL XB0OL9 S-9W112PQT9YF",
            certificate: DigitalCovidCertificate(
                version: "1.0.0",
                name: Name(
                    familyName: "Bertin",
                    givenName: "Olivia",
                    standardizedFamilyName: "BERTIN",
                    standardizedGivenName: "OLIVIA"
                ),
                dateOfBirth: "1976-09-24",
                vaccinationEntries: [
                    VaccinationEntry(
                        diseaseOrAgentTargeted: "840539006",
                        vaccineOrProphylaxis: "1119349007",
                        vaccineMedicinalProduct: "EU/1/21/1529",
                        marketingAuthorizationHolder: "ORG-100010771",
                        doseNumber: 2,
                        totalSeriesOfDoses: 2,
                        dateOfVaccination: "2021-06-24",
                        countryOfVaccination: "DE",
                        certificateIssuer: "Robert Koch-Institut",
                        uniqueCertificateIdentifier: "01DE/00000/1119349007/0FG4PAI5YMVTI5QC7UW79YWC6"
                    )
                ],
                testEntries: nil,
                recoveryEntries: nil
            ),
            header: CBORWebTokenHeader(
                issuer: "DE",
                issuedAt: Date(timeIntervalSince1970: 1619167131),
                expirationTime: Date(timeIntervalSince1970: 1622725423)
            )
        )
    }()

    private lazy var testDataTestCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN%TSMAHN-HVN8J7UQMJ4/36 L-AHIT91RO4.S-OP %I83V8H9GJLUW5NW6SA3/-2E%5G%5TW5A 6YO6XL6Q3QR$P*NI92K*F2-8B0DJV1JD7U:CJX3CJ7J:ZJ83BTH2R638DJC0J*PIR8T3WS9.S*IJ5OI9YI:8DVFC%PD:NK8WCDAB2DNAHLW 70SO:GOLIROGO3T5ZXK9UO GOP*OSV8WP4K166K8A 6:-OGU6927CORX8Q6I4/$R/ER/ QXZOZZOWP4:/6F0P6HPE65V77ZJ82HPPEPHCRTWA+DPL*OCHP7IRZSP:WBW+QYQ6-B5B11XEDW33D8C. C290AQ5EPPQF67460R6646O59EB9:PE+.PTW5F$PI11UH97-5ZT5VZP0JEWYH:PIREGMCIGDB3LKDVAC7JLKB8UJ06JSVBDKBXEB0VL//ET2ADMG5JD*5ADK45TMN95ZTM+CSUHQN%A400H%UBT16Y5+Z9  38CRVS1I$6P+1VWU5:U2:UI36/8HTWU%/EYUUPWEBSHFKVHIM$AF5JRZ$FKCTYUD$PMYTF6%HJ29H/DA BT 36*N0FCZDRKWBGRINNNRAT94KZ5C95N38TBRJ*CF-7RBA1MOHQT1V472AV86O000*JCLCJ",
            certificate: DigitalCovidCertificate(
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
                issuedAt: Date(timeIntervalSince1970: 1619167131),
                expirationTime: Date(timeIntervalSince1970: 1622725423)
            )
        )
    }()

    private lazy var testDataRecoveryCertificate: TestData = {
        TestData(
            input: hcPrefix + "6BFOXN%TSMAHN-HVN8J7UQMJ4/36 L-AH+UC1RO4.S-OPT-I9QKUXI.I5HCF-+AF/8X*G-O9UVPQRHIY1VS1NQ1 WUQRELS4 CTHE7L4LXTC%*400THMVL%20YCZ/KD*S+*4KCTBYKGVV+TV F76AL**I$MV4$0ADF0NNNIV+*4.$S6ZC0JBW63MD34LT483F 2K%5PF5RBQ746B46O1N646EN95O5PF6846A$Q 76SW6SH932QXF7AC5ADNXMQ*Q6NY4 478L6IWM$S4O65YR60D4%IUOD4*EV3LCIS8DKD5C9PG9QVA0932QE+G9AXG/01%CMPK95%L//6JWE/.Q100R$FTM8*N9TL2A-FUTVC1OJ$5I5UH8T-0OG60NJOQ3T%80C6S23OS-5172W1CH$6:7Q5$VT6EY$NY+LV$2R3A1MMLHP2/L7O59SG6.2..TYUVNYT0G6-27$WBZP6NM13.60R3GSMF4ARSV*JO5PU.DGE39Y1GY8RN004GF 2",
            certificate: DigitalCovidCertificate(
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
                issuedAt: Date(timeIntervalSince1970: 1619167131),
                expirationTime: Date(timeIntervalSince1970: 1622725423)
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

    private lazy var keyIdentifierTestDatas = [
        KeyIdentifierTestData(
            input: "HC1:6BFOXN%TSMAHN-HXZS46PH.CW:I14QM52%IT1WG%MP8*I5J5HGRV3GGJLN9L6ATSA3/-2E%5G%5TW5A 6+O6XL6Q3QR$P*NI92KQTT-8B+7KDZIE9JVTI2/B3DJ2OIZ0KZPIGFTH.SM7JC0J*PIQ SX+3/JT2OI5OI9YI:8D-FD%PDGZKL9CDAB2DNAHLW 70SO:GOLIROGO3T5ZXKWUPWGO8IQY42C OD95O7NWI63DRFW5Y*O52SM645WR1SOD87DYOIW6DHPN47L956D6XHQ1EPUHL-IN5TQWGO+9A+CO-8DCCH.*G8KLQ-I/JK4HGN+IRB8GG9IOIHGFZIK*+I77014NB75EHPSGO0IQG40*E9QU11W5DDAD/9OK5*H9Y46PK9O.0E:7IWMVP4E:7J/M6V82M7YA7B9RT9MZS4: KWP4BD7RG8CU6O8QGU68ORLI5ZHQK0PPPPSQ65SO1YO%XOCCQ$47FHPT*O+K6H87F9SVH4BI5HIGJ6V*DKSZJ9ES:XA%9SHHNE9DKWLU8UF.U2WU13W3XPKHMVP1O+VUAR$T8CJR6DH6I3V17V1CMO5/ON3EA%LSM2T1:1*SHSCRY 5$106LD72",
            output: "yLHLNvSl428="
        ),
        KeyIdentifierTestData(
            input: "HC1:6BFY A008F%RWS3.A18OG9JQ9H78G2TT8XEUU9QMOM5CQMDD%3K MCQ:93E6+Y4 15$UH%:BS.GOV2T RW4D/:0D*SYBTLI20N0F-9N9IP1RMKK/QSDF93VMRIVGAL34VMVE8I3T.UA/BF+B.7I87G8:GOXTDZKDDVREIITG%6N5P5%M5KC55MT9%BYV28C6:5APDG3GMVU4Z8IY254O66QP GH FMK$9.83ZEND3UI$PM+G$ME6J9PYTV0KR/E9ZI*ZEMBG%:2N7A+4K IITYNMPN-B0*T8H+EAUOO7H5%NFH2XTDC6GLORNSDVM1:.V:NMYPH3YA8U1F3BJ15O468PLV79H3N+A6IYKD4MZF2L/IZ0JNVHH0N+79A1WU82LEKL.A7B67BGQWE%A2.V6TXU I1.TCFL119C1+KO*I7K8K3S/YGUR80X4B-4$OVZ0M5$1S:UT4KXJK10W1ELX.LAK7N7BGTC+%D+8A5B7$0G44OP5F6GAZGE77CWU041G/-JT3AE4GB2OO0W7E3.%7+8V1IBFXV$ZN XVU-3ACLW27W1WCFW%WK+6SV9KYM78/S%YO1/N7PRO2TQXOK6PRMSUHDT$V7JLDLUKXR-UI",
            output: "yLHLNvSl428="
        )
    ]
}
// swiftlint:enable line_length

// MARK: - TestData

private struct TestData {
    let input: String
    let certificate: DigitalCovidCertificate
    let header: CBORWebTokenHeader
}

private struct EncryptedTestData {
    let input: String
    let output: String
    let decryptedKey: String
}

private struct KeyIdentifierTestData {
    let input: Base45
    let output: String
}
