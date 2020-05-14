//
//  HTTPClientTests.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
import ExposureNotification
@testable import ENA

class HTTPClientTests: XCTestCase {
    let expectationsTimeout: TimeInterval = 2
    let mockUrl = URL(string: "http://example.com")!
    let tan = "1234"

    private var keys: [ENTemporaryExposureKey] {
        let key = ENTemporaryExposureKey()
        key.keyData = Data(bytes: [1,2,3], count: 3)
        key.rollingPeriod = 1337
        key.rollingStartNumber = 42
        key.transmissionRiskLevel = 8

        return [key]
    }

    func testSubmit_Success() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Submit")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssertNil(error)
    }

    func testSubmit_Error() {
        // Arrange
        let mockURLSession = MockUrlSession(data: nil, response: nil, error: TestError.error)

        let client = HTTPClient(session: mockURLSession)

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
        let mockURLSession = MockUrlSession(data: nil, response: nil, error: TestError.error)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "SpecificError")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == SubmissionError.networkError)
    }

    func testSubmit_ResponseNil() {
        // Arrange
        let mockURLSession = MockUrlSession(data: nil, response: nil, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "ResponseNil")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == SubmissionError.generalError)
    }

    func testSubmit_Response400() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 400, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Response400")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == SubmissionError.invalidPayloadOrHeaders)
    }

    func testSubmit_Response403() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: mockUrl, statusCode: 403, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Response403")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == SubmissionError.invalidTan)
    }

    func testInvalidEmptyExposureConfigurationResponseData() {
        let response = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: "HTTP/2", headerFields: [:])
        let mockURLSession = MockUrlSession(data: nil, response: response, error: nil)

        let client = HTTPClient(configuration: .development, session: mockURLSession)

        let expectation = self.expectation(description: "HTTPClient should have failed.")

        client.exposureConfiguration { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(_):
                XCTAssertTrue(true)
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }

    func testValidExposureConfigurationResponseData() throws {
        let validSignedPayloadData = try Sap_SignedPayload.valid().serializedData()
        let response = HTTPURLResponse(url: mockUrl, statusCode: 200, httpVersion: "HTTP/2", headerFields: [:])
        let mockURLSession = MockUrlSession(data: validSignedPayloadData, response: response, error: nil)

        let client = HTTPClient(configuration: .development, session: mockURLSession)

        let expectation = self.expectation(description: "HTTPClient should have succeeded.")

        client.exposureConfiguration { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(_):
               XCTFail("a valid configuration response should yield a successful HTTP client result.")
            }
        }
        waitForExpectations(timeout: expectationsTimeout)
    }
}

enum TestError: Error {
    case error
}

// MARK: Creating a valid signed payload

private extension Sap_RiskScoreParameters.DaysSinceLastExposureRiskParameters {
    static func valid() -> Self {
        Sap_RiskScoreParameters.DaysSinceLastExposureRiskParameters.with {
            $0.ge14Days = .unspecified
            $0.ge12Lt14Days = .unspecified
            $0.ge10Lt12Days = .unspecified
            $0.ge8Lt10Days = .unspecified
            $0.ge6Lt8Days = .unspecified
            $0.ge4Lt6Days = .unspecified
            $0.ge2Lt4Days = .unspecified
            $0.ge0Lt2Days = .unspecified
        }
    }
}

private extension Sap_RiskScoreParameters.AttenuationRiskParameters {
    static func valid() -> Self {
        Sap_RiskScoreParameters.AttenuationRiskParameters.with {
            $0.gt73Dbm = .unspecified
            $0.gt63Le73Dbm = .unspecified
            $0.gt51Le63Dbm = .unspecified
            $0.gt33Le51Dbm = .unspecified
            $0.gt27Le33Dbm = .unspecified
            $0.gt15Le27Dbm = .unspecified
            $0.gt10Le15Dbm = .unspecified
            $0.lt10Dbm = .unspecified
        }
    }
}

private extension Sap_RiskScoreParameters.DurationRiskParameters {
    static func valid() -> Self {
        Sap_RiskScoreParameters.DurationRiskParameters.with {
            $0.eq0Min = .unspecified
            $0.gt0Le5Min = .unspecified
            $0.gt5Le10Min = .unspecified
            $0.gt10Le15Min = .unspecified
            $0.gt15Le20Min = .unspecified
            $0.gt20Le25Min = .unspecified
            $0.gt25Le30Min = .unspecified
            $0.gt30Min = .unspecified
        }
    }
}

private extension Sap_RiskScoreParameters.TransmissionRiskParameters {
    static func valid() -> Self {
        Sap_RiskScoreParameters.TransmissionRiskParameters.with {
            $0.appDefined1 = .unspecified
            $0.appDefined2 = .unspecified
            $0.appDefined3 = .unspecified
            $0.appDefined4 = .unspecified
            $0.appDefined5 = .unspecified
            $0.appDefined6 = .unspecified
            $0.appDefined7 = .unspecified
            $0.appDefined8 = .unspecified
        }
    }
}

private extension Sap_RiskScoreParameters {
    static func valid() -> Self {
        Sap_RiskScoreParameters.with {
            $0.daysSinceLastExposure = .valid()

            $0.attenuation = .valid()
            $0.attenuationWeight = 0.5

            $0.duration = .valid()
            $0.durationWeight = 0.5

            $0.transmission = .valid()
            $0.transmissionWeight = 0.5
        }
    }
}

private extension Sap_SignedPayload {
    static func valid() -> Self {
        Sap_SignedPayload.with {
            $0.payload = try! Sap_RiskScoreParameters.valid().serializedData()
        }
    }
}
