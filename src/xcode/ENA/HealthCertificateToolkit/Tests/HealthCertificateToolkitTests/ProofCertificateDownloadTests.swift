//
// 🦠 Corona-Warn-App
//


import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

final class ProofCertificateDownloadTests: XCTestCase {

    func test_When_fetchProofCertificate_Then_CorrectDataIsReturned() throws {
        let proofCertificateDownload = ProofCertificateDownload()
        let certificateAccess = DigitalGreenCertificateAccess()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(
                data: testData.input.data(using: .utf8),
                response: makeResponse(withStatusCode: 200),
                error: nil
            )
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input], with: httpServiceStub) { [weak self] result in
            guard case let .success(_base45) = result,
                  let base45 = _base45 else {
                XCTFail("Success expected.")
                return
            }

            let result = certificateAccess.extractDigitalGreenCertificate(from: base45)
            guard case let .success(proofCertificate) = result else {
                XCTFail("Success expected.")
                return
            }

            XCTAssertEqual(proofCertificate, self?.testData.output)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_When_fetchWithBrokenBase45_Then_NilSuccessIsReturned() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: ["==NOBase45=="], with: httpServiceStub) {result in
            guard case let .success(proofCertificateData) = result else {
                XCTFail("Success expected.")
                resultExpectation.fulfill()
                return
            }

            XCTAssertEqual(proofCertificateData, nil)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_fetchProofCertificate_When_ServerErrorOccurs_Then_ServerErrorReturned() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(
                data: nil,
                response: makeResponse(withStatusCode: 542),
                error: nil
            )
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input], with: httpServiceStub) { result in
            guard case let .failure(error) = result else {
                XCTFail("Error expected.")
                return
            }

            XCTAssertEqual(error, .PC_SERVER_ERROR)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_fetchProofCertificate_When_TransportErrorOccurs_Then_NetworkErrorReturned() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [
            // Error != nil, means that there was a transport error.
            HTTPServiceStub.Completion(data: nil, response: nil, error: DummyError())
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input], with: httpServiceStub) { result in
            guard case let .failure(error) = result else {
                XCTFail("Error expected.")
                return
            }

            XCTAssertEqual(error, .PC_NETWORK_ERROR)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_fetchProofCertificate_When_ResponseNil_Then_NetworkErrorReturned() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(data: nil, response: nil, error: nil)
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input], with: httpServiceStub) { result in
            guard case let .failure(error) = result else {
                XCTFail("Error expected.")
                return
            }

            XCTAssertEqual(error, .PC_NETWORK_ERROR)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_When_fetchSucceedsWithAtLeastOneCertificate_Then_proofCertIsReturned() throws {

        let proofCertificateDownload = ProofCertificateDownload()
        let certificateAccess = DigitalGreenCertificateAccess()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            ),
            HTTPServiceStub.Completion(
                data: testData.input.data(using: .utf8),
                response: makeResponse(withStatusCode: 200),
                error: nil
            ),
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            )
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input, testData.input, testData.input], with: httpServiceStub) { [weak self] result in
            guard case let .success(_proofCertificateData) = result,
                  let proofCertificateData = _proofCertificateData else {
                XCTFail("Success expected.")
                return
            }

            let result = certificateAccess.extractDigitalGreenCertificate(from: proofCertificateData)
            guard case let .success(proofCertificate) = result else {
                XCTFail("Success expected.")
                return
            }

            XCTAssertEqual(proofCertificate, self?.testData.output)

            // 1 completion is left, because the fetch should return success with the 2. certificate. The 3. certificate should not be send to the server, and 1 completion remains.
            XCTAssertEqual(httpServiceStub.completions.count, 1)

            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_When_fetchFailsWithSeveralCertificates_Then_FetchReturnsNil() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            ),
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            )
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input, testData.input], with: httpServiceStub) { result in
            guard case let .success(proofCertificateData) = result else {
                XCTFail("Success expected.")
                resultExpectation.fulfill()
                return
            }

            XCTAssertEqual(proofCertificateData, nil)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func test_When_fetchWithNotEligibleCertificates_Then_FetchReturnsNilSuccess() throws {
        let proofCertificateDownload = ProofCertificateDownload()

        let httpServiceStub = HTTPServiceStub(completions: [
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            ),
            HTTPServiceStub.Completion(
                data: nil,
                // 400 - Invalid request (e.g incorrect CBOR encoding)
                response: makeResponse(withStatusCode: 400),
                error: nil
            )
        ])

        let resultExpectation = expectation(description: "Fetch should return a result.")

        proofCertificateDownload.fetchProofCertificate(for: [testData.input, testData.input], with: httpServiceStub) { result in
            guard case let .success(proofCertificateData) = result else {
                XCTFail("Success expected.")
                resultExpectation.fulfill()
                return
            }

            XCTAssertEqual(proofCertificateData, nil)
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    private lazy var testData: TestData = {
        TestData (
            input: hcPrefix+"6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I",
            output: DigitalGreenCertificate(
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
                ]
            )
        )
    }()

    private func makeResponse(withStatusCode statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }

}

struct DummyError: Error {}

class HTTPServiceStub: HTTPServiceProtocol {
    struct Completion {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    public init(
        completions: [Completion]
    ) {
        self.completions = completions
    }

    var completions: [Completion]

    public func execute(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let nextCompletion = completions.first
        completions.removeFirst()
        completion(nextCompletion?.data, nextCompletion?.response, nextCompletion?.error)
    }
}

