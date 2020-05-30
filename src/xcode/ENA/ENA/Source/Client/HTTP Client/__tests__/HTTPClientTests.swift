// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import ENA
import ExposureNotification
import XCTest

final class HTTPClientTests: XCTestCase {
    let binFileSize = 501
    let sigFileSize = 144
    let expectationsTimeout: TimeInterval = 2
    let mockUrl = URL(string: "http://example.com")!
    let tan = "1234"

    private var keys: [ENTemporaryExposureKey] {
        let key = ENTemporaryExposureKey()
        key.keyData = Data(bytes: [1, 2, 3], count: 3)
        key.rollingPeriod = 1337
        key.rollingStartNumber = 42
        key.transmissionRiskLevel = 8

        return [key]
    }

    func testAvailableDays_Success() {
        let responseString =
            """
            ["2020-05-01", "2020-05-02"]
            """
        let responseData = responseString.data(using: .utf8)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)
        let expectation = self.expectation(
            description: "expect successful result"
        )
        client.availableDays { result in
            switch result {
            case let .success(days):
                XCTAssertEqual(
                    days,
                    ["2020-05-01", "2020-05-02"]
                )
                expectation.fulfill()
            case let .failure(error):
                XCTFail("a valid response should never yiled an error like \(error)")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testAvailableDays_StatusCodeNotAccepted() {
        let responseString =
            """
            ["2020-05-01", "2020-05-02"]
            """
        let responseData = responseString.data(using: .utf8)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)

        let expectation = self.expectation(
            description: "expect error result"
        )
        client.availableDays { result in
            switch result {
            case .success:
                XCTFail("an invalid response should never yield success")
            case .failure:
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    // The hours of a given day can be missing
    func testAvailableHours_NotFound() {
        let responseString =
            """
            [1,2,3,4,5]
            """
        let responseData = responseString.data(using: .utf8)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)
        let expectation = self.expectation(
            description: "expect successful result but empty"
        )
        client.availableHours(day: "2020-05-12") { result in
            switch result {
            case let .success(hours):
                XCTAssertEqual(
                    hours,
                    []
                )
                expectation.fulfill()
            case let .failure(error):
                XCTFail("a valid response should never yiled an error like \(error)")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testAvailableHours_Success() {
        let responseString =
            """
            [1,2,3,4,5]
            """
        let responseData = responseString.data(using: .utf8)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)
        let expectation = self.expectation(
            description: "expect successful result"
        )
        client.availableHours(day: "2020-05-12") { result in
            switch result {
            case let .success(hours):
                XCTAssertEqual(
                    hours,
                    [1, 2, 3, 4, 5]
                )
                expectation.fulfill()
            case let .failure(error):
                XCTFail("a valid response should never yiled an error like \(error)")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testFetchHour_InvalidPayload() throws {
        let responseData = "hello world".data(using: .utf8)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)

        let failureExpectation = expectation(
            description: "expect error result"
        )

        client.fetchHour(1, day: "2020-05-01") { result in
            switch result {
            case .success:
                XCTFail("an invalid response should never cause success")
            case .failure:
                failureExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testFetchHour_Success() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
        let responseData = try Data(contentsOf: url)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)

        let successExpectation = expectation(
            description: "expect error result"
        )

        client.fetchHour(1, day: "2020-05-01") { result in
            defer { successExpectation.fulfill() }
            switch result {
            case let .success(sapPackage):
                self.assertPackageFormat(for: sapPackage)
            case let .failure(error):
                XCTFail("a valid response should never yield and error like: \(error)")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    private func assertPackageFormat(for downloadedPackage: SAPDownloadedPackage) {
        XCTAssertEqual(downloadedPackage.bin.count, binFileSize)
        XCTAssertEqual(downloadedPackage.signature.count, sigFileSize)
    }

    func testFetchDay_Success() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
        let responseData = try Data(contentsOf: url)

        let mockResponse = HTTPURLResponse(
            url: mockUrl,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let session = MockUrlSession(
            data: responseData,
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: session)

        let successExpectation = expectation(
            description: "expect error result"
        )

        client.fetchDay("2020-05-01") { result in
            defer { successExpectation.fulfill() }
            switch result {
            case let .success(sapPackage):
                self.assertPackageFormat(for: sapPackage)
            case let .failure(error):
                XCTFail("a valid response should never yield and error like: \(error)")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmit_Success() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(
            // cannot be nil since this is not a a completion handler can be in (response + nil body)
            data: Data(),
            nextResponse: mockResponse,
            error: nil
        )
        let client = HTTPClient(configuration: .fake, session: mockURLSession)
        let expectation = self.expectation(description: "completion handler is called without an error")

        // Act
        client.submit(keys: keys, tan: tan) { error in
            defer { expectation.fulfill() }
            XCTAssertTrue(error == nil)
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmit_Error() {
        // Arrange
        let mockURLSession = MockUrlSession(data: nil, nextResponse: nil, error: TestError.error)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)

        let expectation = self.expectation(description: "Error")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssertNotNil(error)
    }

    func testSubmit_SpecificError() {
        // Arrange
        let mockURLSession = MockUrlSession(data: nil, nextResponse: nil, error: TestError.error)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)
        let expectation = self.expectation(description: "SpecificError")

        // Act
        client.submit(keys: keys, tan: tan) { error in
            defer {
                expectation.fulfill()
            }
            guard let error = error else {
                XCTFail("expected there to be an error")
                return
            }

            if case let SubmissionError.other(otherError) = error {
                XCTAssertNotNil(otherError)
            } else {
                XCTFail("error mismatch")
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmit_ResponseNil() {
        // Arrange
        let mockURLSession = MockUrlSession(data: nil, nextResponse: nil, error: nil)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)
        let expectation = self.expectation(description: "ResponseNil")

        // Act
        client.submit(keys: keys, tan: tan) { error in
            defer {
                expectation.fulfill()
            }
            guard let error = error else {
                XCTFail("We expect an error")
                return
            }
            guard case SubmissionError.other = error else {
                XCTFail("We expect error to be of type other")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmit_Response400() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 400, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(
            // Cannot be nil since response is not nil
            data: Data(),
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: mockURLSession)

        let expectation = self.expectation(description: "Response400")

        // Act
        client.submit(keys: keys, tan: tan) { error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case SubmissionError.invalidPayloadOrHeaders = error else {
                XCTFail("We expect error to be of type invalidPayloadOrHeaders")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmit_Response403() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 403, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(
            // Cannot be nil since response is not nil
            data: Data(),
            nextResponse: mockResponse,
            error: nil
        )

        let client = HTTPClient(configuration: .fake, session: mockURLSession)

        let expectation = self.expectation(description: "Response403")

        // Act
        client.submit(keys: keys, tan: tan) { error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case SubmissionError.invalidTan = error else {
                XCTFail("We expect error to be of type invalidTan")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testInvalidEmptyExposureConfigurationResponseData() {
        let response = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: "HTTP/2", headerFields: [:])
        let mockURLSession = MockUrlSession(data: nil, nextResponse: response, error: nil)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)
        let expectation = self.expectation(description: "HTTPClient should have failed.")

        client.exposureConfiguration { config in
            XCTAssertNil(config, "configuration should be nil when data is invalid")
            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testValidExposureConfigurationResponseData() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
        let responseData = try Data(contentsOf: url)

        let response = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: "HTTP/2", headerFields: [:])
        let mockURLSession = MockUrlSession(data: responseData, nextResponse: response, error: nil)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)
        let expectation = self.expectation(description: "HTTPClient should have succeeded.")

        client.exposureConfiguration { config in
            XCTAssertNotNil(config, "configuration should not be nil for valid responses")
            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testValidExposureConfigurationDataBut404Response() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
        let responseData = try Data(contentsOf: url)

        let response = HTTPURLResponse(url: mockUrl, statusCode: 404, httpVersion: "HTTP/2", headerFields: [:])
        let mockURLSession = MockUrlSession(data: responseData, nextResponse: response, error: nil)

        let client = HTTPClient(configuration: .fake, session: mockURLSession)

        let expectation = self.expectation(description: "HTTPClient should have failed.")

        client.exposureConfiguration { configuration in
            XCTAssertNil(
                configuration, "a 404 configuration response should yield an error - not a success"
            )
            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationsTimeout)
    }
}

enum TestError: Error {
    case error
}

// MARK: Creating a valid signed payload

//
// private extension SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
//    static func valid() -> Self {
//        SAP_RiskScoreParameters.DaysSinceLastExposureRiskParameters.with {
//            $0.ge14Days = .unspecified
//            $0.ge12Lt14Days = .unspecified
//            $0.ge10Lt12Days = .unspecified
//            $0.ge8Lt10Days = .unspecified
//            $0.ge6Lt8Days = .unspecified
//            $0.ge4Lt6Days = .unspecified
//            $0.ge2Lt4Days = .unspecified
//            $0.ge0Lt2Days = .unspecified
//        }
//    }
// }

// private extension SAP_RiskScoreParameters.AttenuationRiskParameters {
//    static func valid() -> Self {
//        SAP_RiskScoreParameters.AttenuationRiskParameters.with {
//            $0.gt73Dbm = .unspecified
//            $0.gt63Le73Dbm = .unspecified
//            $0.gt51Le63Dbm = .unspecified
//            $0.gt33Le51Dbm = .unspecified
//            $0.gt27Le33Dbm = .unspecified
//            $0.gt15Le27Dbm = .unspecified
//            $0.gt10Le15Dbm = .unspecified
//            $0.lt10Dbm = .unspecified
//        }
//    }
// }
//
// private extension SAP_RiskScoreParameters.DurationRiskParameters {
//    static func valid() -> Self {
//        SAP_RiskScoreParameters.DurationRiskParameters.with {
//            $0.eq0Min = .unspecified
//            $0.gt0Le5Min = .unspecified
//            $0.gt5Le10Min = .unspecified
//            $0.gt10Le15Min = .unspecified
//            $0.gt15Le20Min = .unspecified
//            $0.gt20Le25Min = .unspecified
//            $0.gt25Le30Min = .unspecified
//            $0.gt30Min = .unspecified
//        }
//    }
// }
//
// private extension SAP_RiskScoreParameters.TransmissionRiskParameters {
//    static func valid() -> Self {
//        SAP_RiskScoreParameters.TransmissionRiskParameters.with {
//            $0.appDefined1 = .unspecified
//            $0.appDefined2 = .unspecified
//            $0.appDefined3 = .unspecified
//            $0.appDefined4 = .unspecified
//            $0.appDefined5 = .unspecified
//            $0.appDefined6 = .unspecified
//            $0.appDefined7 = .unspecified
//            $0.appDefined8 = .unspecified
//        }
//    }
// }
//
// private extension SAP_RiskScoreParameters {
//    static func valid() -> Self {
//
//        SAP_RiskScoreParameters.with {
//
//
//            $0.daysSinceLastExposure = .valid()
//
//            $0.attenuation = .valid()
//            $0.attenuationWeight = 0.5
//
//            $0.duration = .valid()
//            $0.durationWeight = 0.5
//
//            $0.transmission = .valid()
//            $0.transmissionWeight = 0.5
//        }
//    }
//    func asSignedPayload() throws -> Sap_SignedPayload {
//        try Sap_SignedPayload.with {
//            let payload = try serializedData()
//            $0.payload = payload
//        }
//    }
// }

// private extension Sap_SignedPayload {
//
////    static func valid() -> Self {
////        Sap_SignedPayload.with {
////            $0.payload = try! SAP_RiskScoreParameters.valid().serializedData()
////        }
////    }
// }
