//
//  ExposureDetectorTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 07.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//
import XCTest
@testable import ENA
import ExposureNotification

final class ENATests: XCTestCase {

    func testSuccessfulDetection() throws {
        let configuration = ENExposureConfiguration()
        let k0 = ENTemporaryExposureKey()
        let newKeys = [k0]
        let session = MockExposureDetectionSession(configuration: configuration)
        session.activateResult = nil // no error
        session.addDiagnosisKeysResult = nil // no error
        let info = ENExposureInfo()
        session.getExposureInfoResult = ExposureInfoResult(info: [info], done: true, error: nil)
        let summary = ENExposureDetectionSummary()
        session.finishedDiagnosisKeysResult = FinishedDiagnosisKeysResult(summary: summary, error: nil)

        let delegate = BlockBasedExposureDetectorDelegate()

        let finishExpectation = expectation(description: "didFinish is called with correct values")
        let didStartIsCalled = expectation(description: "didStart is called")

        delegate.didStart = { _ in
            didStartIsCalled.fulfill()
        }
        delegate.didFail = { (_, _) in
            XCTFail("didFail should not be called for a successful detection")
        }
        delegate.didFinish = { (_, _) in
            finishExpectation.fulfill()
        }
        let detector = ExposureDetector(configuration: configuration, newKeys: newKeys, session: session, delegate: delegate)
        detector.resume()
        wait(for: [didStartIsCalled, finishExpectation], timeout: 1.0)
    }

    func testDetectionWithErrorDuringActivation() throws {
        let configuration = ENExposureConfiguration()
        let k0 = ENTemporaryExposureKey()
        let newKeys = [k0]
        let session = MockExposureDetectionSession(configuration: configuration)
        session.activateResult = "activation error"
        session.addDiagnosisKeysResult = nil // no error
        let info = ENExposureInfo()
        session.getExposureInfoResult = ExposureInfoResult(info: [info], done: true, error: nil)
        let summary = ENExposureDetectionSummary()
        session.finishedDiagnosisKeysResult = FinishedDiagnosisKeysResult(summary: summary, error: nil)

        let delegate = BlockBasedExposureDetectorDelegate()

        let didStartIsCalled = expectation(description: "didStart is called")
        let didFailIsCalled = expectation(description: "didFail is called")

        delegate.didStart = { _ in
            didStartIsCalled.fulfill()
        }
        delegate.didFail = { (_, error) in
            XCTAssertTrue(error as! String == "activation error")
            didFailIsCalled.fulfill()
        }
        delegate.didFinish = { (_, summary) in
            XCTFail("not called")

        }
        let detector = ExposureDetector(configuration: configuration, newKeys: newKeys, session: session, delegate: delegate)
        detector.resume()
        wait(for: [didStartIsCalled, didFailIsCalled], timeout: 1.0)
    }
}

// Make `String` compatible to `Error` - pure convenience
extension String: Error {}

fileprivate struct ExposureInfoResult {
    let info: [ENExposureInfo]?
    let done: Bool
    let error: Error?
}

fileprivate struct FinishedDiagnosisKeysResult {
    let summary: ENExposureDetectionSummary?
    let error: Error?
}

fileprivate class MockExposureDetectionSession : ExposureDetectionSession {
    init(configuration: ENExposureConfiguration) {
        self.configuration = configuration
    }

    var configuration: ENExposureConfiguration

    var dispatchQueue = DispatchQueue.main

    var maximumKeyCount = 10

    var activateResult: Error?

    func activate(completionHandler: @escaping ENErrorHandler) {
        completionHandler(/* no error */ activateResult)
    }

    var addDiagnosisKeysResult: ENError?

    func addDiagnosisKeys(_ keys: [ENTemporaryExposureKey], completionHandler: @escaping ENErrorHandler) {
        completionHandler(addDiagnosisKeysResult)
    }

    var finishedDiagnosisKeysResult: FinishedDiagnosisKeysResult?
    func finishedDiagnosisKeys(completionHandler: @escaping ENExposureDetectionFinishCompletion) {
        completionHandler(finishedDiagnosisKeysResult?.summary, finishedDiagnosisKeysResult?.error)
    }

    var getExposureInfoResult: ExposureInfoResult?
    func getExposureInfo(withMaximumCount maximumCount: Int, completionHandler: @escaping ENGetExposureInfoCompletion) {
        completionHandler(getExposureInfoResult?.info, getExposureInfoResult?.done ?? true, getExposureInfoResult?.error)
    }
}

fileprivate final class BlockBasedExposureDetectorDelegate: ExposureDetectorDelegate {
    var didStart: ((ExposureDetector) -> Void)?
    var didFinish: ((ExposureDetector, ENExposureDetectionSummary) -> Void)?
    var didFail: ((ExposureDetector, Error) -> Void)?

    func exposureDetectorDidStart(_ detector: ExposureDetector) {
        didStart?(detector)
    }

    func exposureDetectorDidFinish(_ detector: ExposureDetector, summary: ENExposureDetectionSummary) {
        didFinish?(detector, summary)
    }

    func exposureDetectorDidFail(_ detector: ExposureDetector, error: Error) {
        didFail?(detector, error)
    }
}
