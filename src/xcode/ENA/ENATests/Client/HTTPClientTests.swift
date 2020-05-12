//
//  HTTPClientTests.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
@testable import ENA
@testable import ExposureNotification

class HTTPClientTests: XCTestCase {
    let expectationsTimeout: TimeInterval = 2

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
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Submit")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

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

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

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

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

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

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

        // Assert
        XCTAssert(error == SubmissionError.generalError)
    }

    func testSubmit_Response400() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Response400")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

        // Assert
        XCTAssert(error == SubmissionError.invalidPayloadOrHeaders)
    }

    func testSubmit_Response403() {
        // Arrange
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 403, httpVersion: nil, headerFields: nil)
        let mockURLSession = MockUrlSession(data: nil, response: mockResponse, error: nil)

        let client = HTTPClient(session: mockURLSession)

        let expectation = self.expectation(description: "Response403")
        var error: SubmissionError?

        // Act
        client.submit(keys: keys, tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout, handler: nil)

        // Assert
        XCTAssert(error == SubmissionError.invalidTan)
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    override func resume() {
        completion()
    }
}

class MockUrlSession: URLSession {
    let data: Data?
    let response: URLResponse?
    let error: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, self.response, self.error)
        }
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, self.response, self.error)
        }
    }
}

enum TestError: Error {
    case error
}
