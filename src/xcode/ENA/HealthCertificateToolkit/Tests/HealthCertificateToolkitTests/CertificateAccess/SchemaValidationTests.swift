//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import HealthCertificateToolkit

// swiftlint:disable type_body_length
class SchemaValidationTests: XCTestCase {
    
    func test_When_DecodeVaccinationCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfBirth
        /// -Wrong format for dateOfVaccination
        /// -uniqueCertificateIdentifier length > 80
        let fakeCertificate = DigitalCovidCertificate.fake(
            dateOfBirth: "NODateOfBirth",
            vaccinationEntries: [
                VaccinationEntry.fake(
                    dateOfVaccination: "NODateOfVaccination",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing eLorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalCovidCertificateFake.makeBase45Fake(certificate: fakeCertificate, header: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalCovidCertificate(from: base45Fake)

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
        let containsNODateOfVaccination = innerSchemaErrors.contains {
            $0.description.contains("'NODateOfVaccination' does not match pattern")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 80"
        }

        XCTAssertEqual(innerSchemaErrors.count, 2)
        XCTAssertTrue(containsNODateOfVaccination)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeTestCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfBirth
        /// -Wrong format for dateTimeOfSampleCollection
        /// -uniqueCertificateIdentifier length > 80
        let fakeCertificate = DigitalCovidCertificate.fake(
            dateOfBirth: "NotADateOfBirth",
            testEntries: [
                TestEntry.fake(
                    dateTimeOfSampleCollection: "NotADateTimeOfSampleCollection",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing eLorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalCovidCertificateFake.makeBase45Fake(certificate: fakeCertificate, header: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalCovidCertificate(from: base45Fake)

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

        let containsDateTimeOfSampleCollectionError = innerSchemaErrors.contains {
            $0.description.contains("NotADateTimeOfSampleCollection' is not a valid RFC 3339 formatted date")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 80"
        }

        XCTAssertEqual(innerSchemaErrors.count, 2)
        XCTAssertTrue(containsDateTimeOfSampleCollectionError)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeRecoveryCertificateFails_Then_SchemaInvalidErrorIsReturned() {
        let certificateAccess = DigitalCovidCertificateAccess()

        /// This data contains data which leads to validation errors.
        /// Schema validation errors:
        /// -Wrong format for dateOfFirstPositiveNAAResult
        /// -uniqueCertificateIdentifier length > 80
        let fakeCertificate = DigitalCovidCertificate.fake(
            dateOfBirth: "NotADateOfBirth",
            recoveryEntries: [
                RecoveryEntry.fake(
                    dateOfFirstPositiveNAAResult: "NotADateOfFirstPositiveNAAResult",
                    certificateValidFrom: "NotACertificateValidFrom",
                    certificateValidUntil: "NotACertificateValidUntil",
                    uniqueCertificateIdentifier: "Lorem ipsum dolor sit amet, consetetur sadipscing eLorem ipsum dolor sit amet, consetetur sadipscing e"
                )
            ]
        )

        let base45FakeResult = DigitalCovidCertificateFake.makeBase45Fake(certificate: fakeCertificate, header: CBORWebTokenHeader.fake())
        guard case let .success(base45Fake) = base45FakeResult else {
            XCTFail("Success expected.")
            return
        }

        let result = certificateAccess.extractDigitalCovidCertificate(from: base45Fake)

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

        let containsDateOfFirstPositiveNAAResultError = innerSchemaErrors.contains {
            $0.description.contains("NotADateOfFirstPositiveNAAResult' does not match pattern")
        }

        let containsCertificateValidFromError = innerSchemaErrors.contains {
            $0.description.contains("NotACertificateValidFrom' does not match pattern")
        }

        let containsCertificateValidUntilError = innerSchemaErrors.contains {
            $0.description.contains("NotACertificateValidUntil' does not match pattern")
        }

        let containsLengthError = innerSchemaErrors.contains {
            $0.description == "Length of string is larger than max length 80"
        }

        XCTAssertEqual(innerSchemaErrors.count, 4)
        XCTAssertTrue(containsDateOfFirstPositiveNAAResultError)
        XCTAssertTrue(containsCertificateValidFromError)
        XCTAssertTrue(containsCertificateValidUntilError)
        XCTAssertTrue(containsLengthError)
    }

    func test_When_DecodeWithFailJSON_Then_SchemaInvalidErrorIsReturned() {
        for failJsonString in validationFailJsonStrings {
            guard let jsonData = failJsonString.data(using: .utf8),
                  let certificate = try? JSONDecoder().decode(DigitalCovidCertificate.self, from: jsonData) else {
                XCTFail("JSON decoding failed.")
                return
            }

            let base45FakeResult = DigitalCovidCertificateFake.makeBase45Fake(certificate: certificate, header: CBORWebTokenHeader.fake())
            guard case let .success(base45Fake) = base45FakeResult else {
                XCTFail("Success expected.")
                return
            }

            let validationResult = DigitalCovidCertificateAccess().extractDigitalCovidCertificate(from: base45Fake)

            guard case let .failure(error) = validationResult,
                  case .HC_JSON_SCHEMA_INVALID(let schemaError) = error,
                  case .VALIDATION_RESULT_FAILED(let innerSchemaErrors) = schemaError else {
                XCTFail("Error expected.")
                return
            }

            let containsDateError = innerSchemaErrors.contains {
                $0.description.contains("does not match pattern")
            }

            XCTAssertTrue(containsDateError)
        }
    }

    func test_When_DecodeWithPassJSON_Then_SuccessReturned() {
        for passJsonString in validationPassJsonStrings {
            guard let jsonData = passJsonString.data(using: .utf8),
                  let certificate = try? JSONDecoder().decode(DigitalCovidCertificate.self, from: jsonData) else {
                XCTFail("JSON decoding failed.")
                return
            }

            let base45FakeResult = DigitalCovidCertificateFake.makeBase45Fake(certificate: certificate, header: CBORWebTokenHeader.fake())
            guard case let .success(base45Fake) = base45FakeResult else {
                XCTFail("Success expected.")
                return
            }

            let validationResult = DigitalCovidCertificateAccess().extractDigitalCovidCertificate(from: base45Fake)
            guard case .success = validationResult else {
                XCTFail("Success expected.")
                return
            }
        }
    }


    private lazy var validationFailJsonStrings: [String] = [
        /// Vaccination Certificate: vaccination date (`dt`) without day (YYYY-MM)
        """
            {
              "dob": "1964-08-12",
              "nam": {
                  "fn": "Mustermann",
                  "fnt": "MUSTERMANN",
                  "gn": "Erika",
                  "gnt": "ERIKA"
              },
              "v": [
                {
                  "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                  "co": "DE",
                  "dn": 2,
                  "dt": "2021-05",
                  "is": "Robert Koch-Institut",
                  "ma": "ORG-100031184",
                  "mp": "EU/1/20/1507",
                  "sd": 2,
                  "tg": "840539006",
                  "vp": "1119349007"
                }
              ],
              "ver": "1.0.0"
            }
        """,
        /// Vaccination Certificate: vaccination date (`dt`) without day and month (YYYY)
        """
            {
              "dob": "1964-08-12",
              "nam": {
                  "fn": "Mustermann",
                  "fnt": "MUSTERMANN",
                  "gn": "Erika",
                  "gnt": "ERIKA"
              },
              "v": [
                {
                  "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                  "co": "DE",
                  "dn": 2,
                  "dt": "2021",
                  "is": "Robert Koch-Institut",
                  "ma": "ORG-100031184",
                  "mp": "EU/1/20/1507",
                  "sd": 2,
                  "tg": "840539006",
                  "vp": "1119349007"
                }
              ],
              "ver": "1.0.0"
            }
        """
    ]

    private lazy var validationPassJsonStrings: [String] = [
        /// Vaccination Certificate:  "German reference case"
        """
            {
              "dob": "1964-08-12",
              "nam": {
                  "fn": "Mustermann",
                  "fnt": "MUSTERMANN",
                  "gn": "Erika",
                  "gnt": "ERIKA"
              },
              "v": [
                {
                  "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                  "co": "DE",
                  "dn": 2,
                  "dt": "2021-05-29",
                  "is": "Robert Koch-Institut",
                  "ma": "ORG-100031184",
                  "mp": "EU/1/20/1507",
                  "sd": 2,
                  "tg": "840539006",
                  "vp": "1119349007"
                }
              ],
              "ver": "1.0.0"
            }
        """,
        /// Vaccination Certificate:  dates (`dob` and `dt`) with time information at midnight
        """
            {
              "r": null,
              "t": null,
              "v": [
                {
                  "ci": "urn:uvci:01:BG:UFR5PLGKU8WDSZK7#0",
                  "co": "BG",
                  "dn": 2,
                  "dt": "2021-03-09T00:00:00",
                  "is": "Ministry of Health",
                  "ma": "ORG-100030215",
                  "mp": "EU/1/20/1528",
                  "sd": 2,
                  "tg": "840539006",
                  "vp": "J07BX03"
                }
              ],
              "dob": "1978-01-26T00:00:00",
              "nam": {
                "fn": "ПЕТКОВ",
                "gn": "СТАМО ГЕОРГИЕВ",
                "fnt": "PETKOV",
                "gnt": "STAMO<GEORGIEV"
              },
              "ver": "1.0.0"
            }
        """,
        /// Vaccination Certificate:  vaccination date (`dt`) with real time information
        """
            {
              "ver" : "1.0.0",
              "nam" : {
                "fn" : "Rogaliński-Król",
                "fnt" : "ROGALINSKI<KROL",
                "gn" : "Stanisław",
                "gnt" : "STANISLAW"
              },
              "dob" : "1958-11-11",
              "v" : [ {
                "tg" : "840539006",
                "vp" : "J07BX03",
                "mp" : "EU/1/21/1529",
                "ma" : "ORG-100030215",
                "dn" : 1,
                "sd" : 2,
                "dt" : "2021-03-18T15:31:00+02:00",
                "co" : "PL",
                "is" : "Centrum e-Zdrowia",
                "ci" : "URN:UVCI:01:PL:1/4F86BBF0865B465F9BDD907C3A2C141F"
              } ]
            }
        """,
        /// Test Certificate:  German reference case
        #"""
            {
                  "dob": "1964-08-12",
                  "nam": {
                    "fn": "Mustermann",
                    "fnt": "MUSTERMANN",
                    "gn": "Erika",
                    "gnt": "ERIKA"
                  },
                  "t": [
                    {
                      "ci": "URN:UVCI:01DE/IZ12345A/5CWLU12RNOB9RXSEOP6FG8#W",
                      "co": "DE",
                      "dr": "2021-05-30T10:30:15Z",
                      "is": "Robert Koch-Institut",
                      "sc": "2021-05-30T10:12:22Z",
                      "tc": "Testzentrum K\u00f6ln Hbf",
                      "tg": "840539006",
                      "tr": "260415000",
                      "tt": "LP217198-3"
                    }
                  ],
                  "ver": "1.0.0"
                }
        """#,
        /// Test Certificate:  date-time (`sc`) with milliseconds
        """
        {
              "ver": "1.0.0",
              "nam": {
                "fn": "Lövström",
                "fnt": "LOEVSTROEM",
                "gn": "Oscar",
                "gnt": "OSCAR"
              },
              "dob": "1958-11-11",
              "t": [
                {
                  "tg": "840539006",
                  "tt": "LP217198-3",
                  "ma": "1232",
                  "sc": "2021-06-02T04:31:14.168957Z",
                  "tr": "260415000",
                  "tc": "Axelsbergs vårdcentral",
                  "co": "SE",
                  "is": "Swedish eHealth Agency",
                  "ci": "URN:UVCI:01:SE:EHM/TSTAX67554312"
                }
              ]
            }
        """,
        /// Recovery Certificate: German reference case
        """
        {
              "dob": "1964-08-12",
              "nam": {
                "fn": "Mustermann",
                "fnt": "MUSTERMANN",
                "gn": "Erika",
                "gnt": "ERIKA"
              },
              "r": [
                {
                  "ci": "URN:UVCI:01DE/5CWLU12RNOB9RXSEOP6FG8#W",
                  "co": "DE",
                  "df": "2021-05-29",
                  "du": "2021-06-15",
                  "fr": "2021-01-10",
                  "is": "Robert Koch-Institut",
                  "tg": "840539006"
                }
              ],
              "ver": "1.0.0"
            }
        """,
        /// Recovery Certificate:  dates (`df`, `du`, `dt`) with time information at midnight
        """
        {
              "r": [
                {
                  "ci": "urn:uvci:01:BG:UFR5PLGKU8WDSZK7#0",
                  "co": "BG",
                  "df": "2021-05-11T00:00:00",
                  "du": "2021-10-28T00:00:00",
                  "fr": "2021-05-01T00:00:00",
                  "is": "Ministry of Health",
                  "tg": "840539006"
                }
              ],
              "t": null,
              "v": null,
              "dob": "1978-01-26T00:00:00",
              "nam": {
                "fn": "ПЕТКОВ",
                "gn": "СТАМО ГЕОРГИЕВ",
                "fnt": "PETKOV",
                "gnt": "STAMO<GEORGIEV"
              },
              "ver": "1.0.0"
            }
        """
    ]
}
