//
//  ExposureSubmissionServiceTests.swift
//  ENATests
//
//  Created by Zildzic, Adnan on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
import ExposureNotification
@testable import ENA

class ExposureSubmissionServiceTests: XCTestCase {
    let expectationsTimeout: TimeInterval = 2
    let tan = "1234"
    let keys = [ENTemporaryExposureKey()]

    func testSubmitExpousure_Success() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "Success")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssertNil(error)
    }

    func testSubmitExpousure_ActivationError() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: .exposureNotificationAuthorization, diagnosisKeysResult: nil)
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "ActivationError")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .enNotEnabled)
    }

    func testSubmitExpousure_NoKeys() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (nil, nil))
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "NoKeys")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .noKeys)
    }

    func testSubmitExpousure_EmptyKeys() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (nil, nil))
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "EmptyKeys")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .noKeys)
    }

    func testSubmitExpousure_NetworkError() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: .networkError)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "NetworkError")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .networkError)
    }

    func testSubmitExpousure_OtherError() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: .invalidPayloadOrHeaders)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "OtherError")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .other)
    }

    func testSubmitExpousure_InvalidTan() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: .invalidTan)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "InvalidTan")
        var error: ExposureSubmissionError?

        // Act
        service.submitExposure(tan: tan) {
            error = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: expectationsTimeout)

        // Assert
        XCTAssert(error == .invalidTan)
    }
}
