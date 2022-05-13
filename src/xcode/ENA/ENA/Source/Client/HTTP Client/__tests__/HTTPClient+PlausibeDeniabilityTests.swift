//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class HTTPClientPlausibleDeniabilityTests: CWATestCase {

	func test_getTestResult_requestPadding() {

		// GIVEN
		let sendResource = PaddingJSONSendResource<TestResultSendModel>(
			TestResultSendModel(
				registrationToken: "123456789"
			)
		)

		// WHEN
		let result = sendResource.encode()

		// THEN
		switch result {
		case let .success(bodyData):
			XCTAssertEqual(bodyData?.count, 250)
		case .failure:
			XCTFail("Padding size is wrong")
		}
	}

	func test_getRegistrationToken_requestPadding() {
		// GIVE
		let sendResource = PaddingJSONSendResource<TeleTanSendModel>(
			TeleTanSendModel(
				key: "123456789",
				keyType: .teleTan
			)
		)

		// WHEN
		let result = sendResource.encode()

		// THEN
		switch result {
		case let .success(bodyData):
			XCTAssertEqual(bodyData?.count, 250)
		case .failure:
			XCTFail("Padding size is wrong")
		}
	}

	func test_getTANForExposureSubmit_requestPadding() {
		
		let sendResource = PaddingJSONSendResource<RegistrationTokenSendModel>(
			RegistrationTokenSendModel(token: "dummyRegToken")
		)
		if case let .success(bodyData) = sendResource.encode() {
			do {
				let data = try XCTUnwrap(bodyData)
				XCTAssertEqual(data.count, 250)
			} catch {
				XCTFail("Should unwrap data object \(error.localizedDescription)")
			}
		} else {
			XCTFail("Wrong padding body size")
		}
	}

	func test_submit_requestPaddingIdenticalForRealAndFake() {
		let noKeys = [ENTemporaryExposureKey]()
		compareSubmitRequestPadding(for: noKeys)

		let lessThan14Keys = (0..<11).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: lessThan14Keys)

		let exactly14Keys = (0..<14).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: exactly14Keys)

		let moreThan14Keys = (0..<23).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: moreThan14Keys)
	}

	private func compareSubmitRequestPadding(for keys: [ENTemporaryExposureKey]) {
		// Setup.
		var realRequestBodySize = Int.max
		var fakeRequestBodySize = Int.min

		// Test.
		let payload = SubmissionPayload(exposureKeys: [], visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: "dummyTan", submissionType: .pcrTest)
		
		let resource = KeySubmissionResource(payload: payload)
		if case let .success(bodyData) = resource.sendResource.encode() {
			do {
				let data = try XCTUnwrap(bodyData)
				realRequestBodySize = data.count
			} catch {
				XCTFail("Should unwrap data object \(error.localizedDescription)")
			}
		} else {
			XCTFail("Wrong padding body size")
		}
		
		let fakeResource = KeySubmissionResource(payload: payload, isFake: true)
		if case let .success(bodyData) = fakeResource.sendResource.encode() {
			do {
				let data = try XCTUnwrap(bodyData)
				fakeRequestBodySize = data.count
			} catch {
				XCTFail("Should unwrap data object \(error.localizedDescription)")
			}
		} else {
			XCTFail("Wrong padding body size")
		}

		XCTAssertEqual(realRequestBodySize, fakeRequestBodySize)
	}
}
