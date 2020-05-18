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

        // Act
        service.submitExposure(tan: tan) { error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case ExposureSubmissionError.enNotEnabled = error else {
                XCTFail("We expect error to be of type enNotEnabled")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmitExpousure_NoKeys() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (nil, nil))
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "NoKeys")

        // Act
        service.submitExposure(tan: tan) { error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case ExposureSubmissionError.noKeys = error else {
                XCTFail("We expect error to be of type expectationsTimeout")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmitExpousure_EmptyKeys() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (nil, nil))
        let client = MockTestClient(submissionError: nil)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "EmptyKeys")

        // Act
        service.submitExposure(tan: tan) {error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case ExposureSubmissionError.noKeys = error else {
                XCTFail("We expect error to be of type noKeys")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmitExpousure_OtherError() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: .invalidPayloadOrHeaders)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "OtherError")

        // Act
        service.submitExposure(tan: tan) { error in
            defer { expectation.fulfill() }
            guard let error = error else {
                XCTFail("error expected")
                return
            }
            guard case ExposureSubmissionError.other = error else {
                XCTFail("We expect error to be of type invalidTan")
                return
            }
        }

        waitForExpectations(timeout: expectationsTimeout)
    }

    func testSubmitExpousure_InvalidTan() {
        // Arrange
        let exposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
        let client = MockTestClient(submissionError: .invalidTan)

        let service = ENAExposureSubmissionService(manager: exposureManager, client: client)
        let expectation = self.expectation(description: "InvalidTan")

        // Act
        service.submitExposure(tan: tan) { error in
            defer {
                expectation.fulfill()
            }
            XCTAssert(error == .invalidTan)
        }

        waitForExpectations(timeout: expectationsTimeout)
    }
}
