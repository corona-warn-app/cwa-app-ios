//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class SRSPreconditionErrorTests: CWATestCase {

	func testDeviceTimeError_Message() {
		// GIVEN
		let sut = SRSPreconditionError.deviceTimeError(.deviceNotSupported)
		
		// THEN
		XCTAssertEqual(
			sut.message,
			String(
				format: AppStrings.ExposureSubmissionDispatch.SRSWarnOthersPreconditionAlert.deviceCheckError,
				sut.errorCode
			)
		)
	}

	func testInsufficientAppUsageTime_Message() {
		// GIVEN
		let sut = SRSPreconditionError.insufficientAppUsageTime
		
		// THEN
		XCTAssertEqual(
			sut.message,
			String(
				format: AppStrings.ExposureSubmissionDispatch.SRSWarnOthersPreconditionAlert.insufficientAppUsageTimeMessage,
				sut.errorCode
			)
		)
	}
	
	func testPositiveTestResultWasAlreadySubmittedWithinThreshold_Message() {
		// GIVEN
		let timeBetweenSubmissionsInDays = 42
		let sut = SRSPreconditionError.positiveTestResultWasAlreadySubmittedWithinThreshold(
			timeBetweenSubmissionsInDays: timeBetweenSubmissionsInDays
		)
		
		// THEN
		XCTAssertEqual(
			sut.message,
			String(
				format: AppStrings.ExposureSubmissionDispatch.SRSWarnOthersPreconditionAlert.positiveTestResultWasAlreadySubmittedWithinThresholdDaysMessage,
				String(timeBetweenSubmissionsInDays),
				sut.errorCode
			)
		)
	}
	
	func testErrorCode_EqualTo_ErrorDescription() {
		// GIVEN
		let sut = SRSPreconditionError.insufficientAppUsageTime
		
		// THEN
		XCTAssertEqual(sut.errorCode, sut.description)
	}
	
	func testDescription() {
		// WHEN
		var sut = SRSPreconditionError.deviceTimeError(.timeIncorrect)
		
		// THEN
		XCTAssertEqual(sut.description, "DEVICE_TIME_INCORRECT")
		
		// WHEN
		sut = .deviceTimeError(.timeUnverified)
		
		// THEN
		XCTAssertEqual(sut.description, "DEVICE_TIME_UNVERIFIED")
		
		// WHEN
		sut = .insufficientAppUsageTime
		
		// THEN
		XCTAssertEqual(sut.description, "MIN_TIME_SINCE_ONBOARDING")
		
		// WHEN
		sut = .positiveTestResultWasAlreadySubmittedWithinThreshold(timeBetweenSubmissionsInDays: 42)
		
		// THEN
		XCTAssertEqual(sut.description, "SUBMISSION_TOO_EARLY")
	}
}
