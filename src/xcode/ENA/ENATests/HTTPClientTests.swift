//
//  HTTPClientTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import XCTest
@testable import ENA

final class HTTPClientTests: XCTestCase {

    func testInvalidEmptyExposureConfigurationResponseData() {
        let session = MockSessionWith { url, completeWith in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/2",
                headerFields: [:]
            )
            completeWith(Data(), response, .noError)
        }
        let client = HTTPClient(configuration: .mock, session: session)

        let expectFailure = expectation(description: "HTTPClient should have failed.")
        client.exposureConfiguration { result in
            switch result {
            case .success(_):
                expectFailure.fulfill()
            case .failure(_):
                XCTAssertTrue(true)
            }
        }
        waitForExpectations(timeout: 1.0)
    }

    func testValidExposureConfigurationResponseData() throws {
        let validSignedPayloadData = try Sap_SignedPayload.valid().serializedData()

        let session = MockSessionWith { url, completeWith in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/2",
                headerFields: [:]
            )

            completeWith(
                validSignedPayloadData,
                response,
                .noError
            )
        }
        let client = HTTPClient(configuration: .mock, session: session)

        let expectSuccess = expectation(description: "HTTPClient should have succeeded.")
        client.exposureConfiguration { result in
            switch result {
            case .success(_):
                expectSuccess.fulfill()
            case .failure(_):
               XCTFail("a valid configuration response should yield a successful HTTP client result.")
            }
        }
        waitForExpectations(timeout: 1.0)
    }
}

// MARK: Test Helper

// Concenience extension to make code more readable. Instead of writing:
// ```swift
//    completeWith(Data(), Response(), nil)
// ```
// You can write:
// ```swift
//    completeWith(Data(), Response(), .noError)
// ```
private extension Optional where Wrapped == Error {
    static let noError: Error? = nil
}

final class MockSessionWith {
    // MARK: Types
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    typealias URLHandler = (_ url: URL, _ done: CompletionHandler) -> Void

    // MARK: Creating a mocked session
    init(handler: @escaping URLHandler) {
        self.handler = handler
    }

    // MARK: Properties
    let handler: URLHandler
}

extension MockSessionWith: Session {
    func sessionTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
        MockSessionTask(url: url, handler: handler, completionHandler: completionHandler)
    }
}

final class MockSessionTask: SessionTask {
    // MARK: Properties
    private let handler: MockSessionWith.URLHandler
    private let completionHandler: MockSessionWith.CompletionHandler
    private let url: URL

    // MARK: Creating a mocked session taks
    init(
        url: URL,
        handler: @escaping MockSessionWith.URLHandler,
        completionHandler: @escaping MockSessionWith.CompletionHandler
    ) {
        self.url = url
        self.handler = handler
        self.completionHandler = completionHandler
    }

    // MARK: SessionTask implementation
    func resume() {
        handler(self.url, self.completionHandler)
    }
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
