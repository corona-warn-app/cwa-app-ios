////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinTests: CWATestCase {

	func testCheckinTransmissionPreparationFiltersSubmittedCheckins() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startDate = Date()
		let endDate = Date(timeIntervalSinceNow: 15 * 60)

		let checkins = [
			Checkin.mock(traceLocationId: try XCTUnwrap("0".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationId: try XCTUnwrap("1".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationId: try XCTUnwrap("2".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationId: try XCTUnwrap("3".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationId: try XCTUnwrap("4".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true)
		]

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: checkins,
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 2)

		XCTAssertEqual(preparedCheckins[0].locationID, try XCTUnwrap("2".data(using: .utf8)))
		XCTAssertEqual(preparedCheckins[1].locationID, try XCTUnwrap("3".data(using: .utf8)))
	}

	func testCheckinProtectedReportsPreparationFiltersSubmittedCheckins() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startDate = Date()
		let endDate = Date(timeIntervalSinceNow: 15 * 60)

		let checkins = [
			Checkin.mock(traceLocationIdHash: try XCTUnwrap("0".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationIdHash: try XCTUnwrap("1".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true),
			Checkin.mock(traceLocationIdHash: try XCTUnwrap("2".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationIdHash: try XCTUnwrap("3".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: false),
			Checkin.mock(traceLocationIdHash: try XCTUnwrap("4".data(using: .utf8)), checkinStartDate: startDate, checkinEndDate: endDate, checkinSubmitted: true)
		]

		// process checkins
		let checkinProtectedReports = service.preparedCheckinProtectedReportsForSubmission(
			checkins: checkins,
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(checkinProtectedReports.count, 2)

		let locationIdHashes = [
			checkinProtectedReports[0].locationIDHash,
			checkinProtectedReports[1].locationIDHash
		]

		let idHash2Count = locationIdHashes.filter {
			let idHash = try? XCTUnwrap("2".data(using: .utf8))
			return $0 == idHash
		}.count

		let idHash3Count = locationIdHashes.filter {
			let idHash = try? XCTUnwrap("3".data(using: .utf8))
			return $0 == idHash
		}.count

		XCTAssertEqual(locationIdHashes.count, 2)
		XCTAssertEqual(idHash2Count, 1)
		XCTAssertEqual(idHash3Count, 1)
	}

    func testCheckinTransmissionPreparation() throws {
        let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let checkin = Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: [checkin],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 5)

		XCTAssertEqual(preparedCheckins[0].transmissionRiskLevel, 4)
		XCTAssertEqual(preparedCheckins[1].transmissionRiskLevel, 6)
		XCTAssertEqual(preparedCheckins[2].transmissionRiskLevel, 7)
		XCTAssertEqual(preparedCheckins[3].transmissionRiskLevel, 8)
		XCTAssertEqual(preparedCheckins[4].transmissionRiskLevel, 8)
    }

	func testCheckinProtectedReportsPreparation() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let traceLocationId: Data = try XCTUnwrap(Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="))

		let checkin = Checkin.mock(
			traceLocationId: traceLocationId,
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let checkinProtectedReports = service.preparedCheckinProtectedReportsForSubmission(
			checkins: [checkin],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(checkinProtectedReports.count, 5)

		let riskLevels = [
			riskLevel(for: checkinProtectedReports[0], traceLocationId: traceLocationId),
			riskLevel(for: checkinProtectedReports[1], traceLocationId: traceLocationId),
			riskLevel(for: checkinProtectedReports[2], traceLocationId: traceLocationId),
			riskLevel(for: checkinProtectedReports[3], traceLocationId: traceLocationId),
			riskLevel(for: checkinProtectedReports[4], traceLocationId: traceLocationId)
		]

		XCTAssertEqual(riskLevels.filter { $0 == 4 }.count, 1)
		XCTAssertEqual(riskLevels.filter { $0 == 6 }.count, 1)
		XCTAssertEqual(riskLevels.filter { $0 == 7 }.count, 1)
		XCTAssertEqual(riskLevels.filter { $0 == 8 }.count, 2)
	}

	func testDerivingWarningTimeInterval() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startOfToday = Calendar.current.startOfDay(for: Date())

		let filteredStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 1, to: startOfToday))
		let filteredEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 8, to: filteredStartDate))

		let keptStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 0, to: startOfToday))
		let keptEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 10, to: keptStartDate))
		let derivedEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 20, to: keptStartDate))

		let expectedStartIntervalNumber = UInt32(keptStartDate.timeIntervalSince1970 / 600)
		let expectedEndIntervalNumber = UInt32(derivedEndDate.timeIntervalSince1970 / 600)

		let checkin1 = Checkin.mock(
			checkinStartDate: filteredStartDate,
			checkinEndDate: filteredEndDate
		)
		let checkin2 = Checkin.mock(
			checkinStartDate: keptStartDate,
			checkinEndDate: keptEndDate
		)

		// process checkins
		let preparedCheckins = service.preparedCheckinsForSubmission(
			checkins: [checkin1, checkin2],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		XCTAssertEqual(preparedCheckins.count, 1)

		XCTAssertEqual(preparedCheckins[0].startIntervalNumber, expectedStartIntervalNumber)
		XCTAssertEqual(preparedCheckins[0].endIntervalNumber, expectedEndIntervalNumber)
	}

	func testCheckinProtectedReportsDerivingWarningTimeInterval() throws {
		let service = MockExposureSubmissionService()
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let startOfToday = Calendar.current.startOfDay(for: Date())

		let filteredStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 1, to: startOfToday))
		let filteredEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 8, to: filteredStartDate))

		let keptStartDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 0, to: startOfToday))
		let keptEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 10, to: keptStartDate))
		let derivedEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: 20, to: keptStartDate))

		let expectedStartIntervalNumber = UInt32(keptStartDate.timeIntervalSince1970 / 600)
		let expectedEndIntervalNumber = UInt32(derivedEndDate.timeIntervalSince1970 / 600)

		let traceLocationId: Data = try XCTUnwrap(Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="))

		let checkin1 = Checkin.mock(
			traceLocationId: traceLocationId,
			checkinStartDate: filteredStartDate,
			checkinEndDate: filteredEndDate
		)
		let checkin2 = Checkin.mock(
			traceLocationId: traceLocationId,
			checkinStartDate: keptStartDate,
			checkinEndDate: keptEndDate
		)

		// process checkins
		let checkinProtectedReports = service.preparedCheckinProtectedReportsForSubmission(
			checkins: [checkin1, checkin2],
			appConfig: appConfig,
			symptomOnset: .daysSinceOnset(0)
		)

		let protectedReport = checkinProtectedReports[0]

		let result = CheckinEncryption().decrypt(
			locationId: traceLocationId,
			encryptedCheckinRecord: protectedReport.encryptedCheckInRecord,
			initializationVector: protectedReport.iv,
			messageAuthenticationCode: protectedReport.mac
		)

		guard case let .success(decryptionResult) = result else {
			if case let .failure(error) = result {
				XCTFail("Decryption failed: \(error)")
			}
			fatalError("Success and failure where handled, this part should never be reached.")
		}

		XCTAssertEqual(checkinProtectedReports.count, 1)

		XCTAssertEqual(decryptionResult.startIntervalNumber, expectedStartIntervalNumber)
		XCTAssertEqual(decryptionResult.startIntervalNumber + decryptionResult.period, expectedEndIntervalNumber)
	}

	// MARK: - Private

	private func riskLevel(
		for protectedReport: SAP_Internal_Pt_CheckInProtectedReport,
		traceLocationId: Data
	) -> UInt32? {
		let result = CheckinEncryption().decrypt(
			locationId: traceLocationId,
			encryptedCheckinRecord: protectedReport.encryptedCheckInRecord,
			initializationVector: protectedReport.iv,
			messageAuthenticationCode: protectedReport.mac
		)

		guard case let .success(decryptionResult) = result else {
			if case let .failure(error) = result {
				XCTFail("Decryption failed: \(error)")
			}
			fatalError("Success and failure where handled, this part should never be reached.")
		}

		return decryptionResult.transmissionRiskLevel
	}
}
