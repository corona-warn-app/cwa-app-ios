////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinSubmissionPreparationTests: CWATestCase {

	func testCheckinTransmissionPreparationFiltersSubmittedCheckins() throws {
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
		let preparedCheckins = checkins.preparedForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
		)

		XCTAssertEqual(preparedCheckins.count, 2)

		XCTAssertEqual(preparedCheckins[0].locationID, try XCTUnwrap("2".data(using: .utf8)))
		XCTAssertEqual(preparedCheckins[1].locationID, try XCTUnwrap("3".data(using: .utf8)))
	}

	func testCheckinProtectedReportsPreparationFiltersSubmittedCheckins() throws {
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
		let checkinProtectedReports = checkins.preparedProtectedReportsForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
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
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let checkin = Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let preparedCheckins = [checkin].preparedForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
		)

		XCTAssertEqual(preparedCheckins.count, 5)

		XCTAssertEqual(preparedCheckins[0].transmissionRiskLevel, 4)
		XCTAssertEqual(preparedCheckins[1].transmissionRiskLevel, 6)
		XCTAssertEqual(preparedCheckins[2].transmissionRiskLevel, 7)
		XCTAssertEqual(preparedCheckins[3].transmissionRiskLevel, 8)
		XCTAssertEqual(preparedCheckins[4].transmissionRiskLevel, 8)
    }

	func testCheckinTransmissionPreparationWithFixedTransmissionRiskLevel() throws {
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let checkin = Checkin.mock(
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let preparedCheckins = [checkin].preparedForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .fixedValue(5)
		)

		XCTAssertEqual(preparedCheckins.count, 21)

		XCTAssertTrue(preparedCheckins.allSatisfy { $0.transmissionRiskLevel == 5 })
	}

	func testCheckinProtectedReportsPreparation() throws {
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let traceLocationId: Data = try XCTUnwrap(Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="))

		let checkin = Checkin.mock(
			traceLocationId: traceLocationId,
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let checkinProtectedReports = [checkin].preparedProtectedReportsForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
		)

		XCTAssertEqual(checkinProtectedReports.count, 5)

		let checkinRecords = checkinProtectedReports.compactMap {
			self.checkinRecord(for: $0, traceLocationId: traceLocationId)
		}.sorted {
			$0.startIntervalNumber < $1.startIntervalNumber
		}

		XCTAssertEqual(checkinRecords[0].transmissionRiskLevel, 4)
		XCTAssertEqual(checkinRecords[1].transmissionRiskLevel, 6)
		XCTAssertEqual(checkinRecords[2].transmissionRiskLevel, 7)
		XCTAssertEqual(checkinRecords[3].transmissionRiskLevel, 8)
		XCTAssertEqual(checkinRecords[4].transmissionRiskLevel, 8)
	}

	func testCheckinProtectedReportsPreparationWithFixedTransmissionRiskLevel() throws {
		let appConfig = CachedAppConfigurationMock.defaultAppConfiguration

		let traceLocationId: Data = try XCTUnwrap(Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="))

		let checkin = Checkin.mock(
			traceLocationId: traceLocationId,
			checkinStartDate: try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -20, to: Date())),
			checkinEndDate: Date()
		)

		// process checkins
		let checkinProtectedReports = [checkin].preparedProtectedReportsForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .fixedValue(5)
		)

		XCTAssertEqual(checkinProtectedReports.count, 21)

		let checkinRecords = checkinProtectedReports.compactMap {
			self.checkinRecord(for: $0, traceLocationId: traceLocationId)
		}.sorted {
			$0.startIntervalNumber < $1.startIntervalNumber
		}

		XCTAssertTrue(checkinRecords.allSatisfy { $0.transmissionRiskLevel == 5 })
	}

	func testDerivingWarningTimeInterval() throws {
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
		let preparedCheckins = [checkin1, checkin2].preparedForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
		)

		XCTAssertEqual(preparedCheckins.count, 1)

		XCTAssertEqual(preparedCheckins[0].startIntervalNumber, expectedStartIntervalNumber)
		XCTAssertEqual(preparedCheckins[0].endIntervalNumber, expectedEndIntervalNumber)
	}

	func testCheckinProtectedReportsDerivingWarningTimeInterval() throws {
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
		let checkinProtectedReports = [checkin1, checkin2].preparedProtectedReportsForSubmission(
			appConfig: appConfig,
			transmissionRiskLevelSource: .symptomsOnset(.daysSinceOnset(0))
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

	private func checkinRecord(
		for protectedReport: SAP_Internal_Pt_CheckInProtectedReport,
		traceLocationId: Data
	) -> SAP_Internal_Pt_CheckInRecord? {
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

		return decryptionResult
	}
}
