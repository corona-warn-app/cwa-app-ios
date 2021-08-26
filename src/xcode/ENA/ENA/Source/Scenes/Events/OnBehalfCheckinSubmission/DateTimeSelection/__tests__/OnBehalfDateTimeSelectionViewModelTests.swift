////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfDateTimeSelectionViewModelTests: XCTestCase {

	func testDynamicTableViewModel() {
		let viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: .mock(),
			onPrimaryButtonTap: { _ in }
		)

		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 5)
	}

	func testCreateCheckin_LocationWithoutStartDateWithDefaultCheckinLength() {
		guard let id = "TraceLocationID".data(using: .utf8),
			  let cryptographicSeed = "CryptographicSeed".data(using: .utf8),
			  let cnPublicKey = "PublicKey".data(using: .utf8) else {
			XCTFail("Failed to encode id into data")
			return
		}

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Zeit für Brot",
			address: "Oeder Weg 15, 60318 Frankfurt am Main",
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey
		)

		let onPrimaryButtonTapExpectation = expectation(description: "onPrimaryButtonTap called")

		let viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: traceLocation,
			onPrimaryButtonTap: { checkin in
				XCTAssertEqual(checkin.traceLocationId, id)
				XCTAssertEqual(checkin.traceLocationIdHash, traceLocation.idHash)
				XCTAssertEqual(checkin.traceLocationVersion, 1)
				XCTAssertEqual(checkin.traceLocationType, .locationTypePermanentFoodService)
				XCTAssertEqual(checkin.traceLocationDescription, "Zeit für Brot")
				XCTAssertEqual(checkin.traceLocationAddress, "Oeder Weg 15, 60318 Frankfurt am Main")
				XCTAssertNil(checkin.traceLocationStartDate)
				XCTAssertNil(checkin.traceLocationEndDate)
				XCTAssertEqual(checkin.traceLocationDefaultCheckInLengthInMinutes, 23)
				XCTAssertEqual(checkin.cryptographicSeed, cryptographicSeed)
				XCTAssertEqual(checkin.cnPublicKey, cnPublicKey)
				XCTAssertEqual(
					checkin.checkinStartDate.timeIntervalSince1970,
					Date().timeIntervalSince1970,
					accuracy: 10
				)
				// defaultCheckInLengthInMinutes of 23 is rounded up to 30
				XCTAssertEqual(
					checkin.checkinEndDate.timeIntervalSince1970,
					Date(timeIntervalSinceNow: 30 * 60).timeIntervalSince1970,
					accuracy: 10
				)
				XCTAssertFalse(checkin.checkinCompleted)
				XCTAssertFalse(checkin.createJournalEntry)
				XCTAssertFalse(checkin.checkinSubmitted)

				onPrimaryButtonTapExpectation.fulfill()
			}
		)

		viewModel.createCheckin()

		waitForExpectations(timeout: .short)
	}

	func testCreateCheckin_LocationWithStartDateWithDefaultCheckinLength() {
		guard let id = "TraceLocationID".data(using: .utf8),
			  let cryptographicSeed = "CryptographicSeed".data(using: .utf8),
			  let cnPublicKey = "PublicKey".data(using: .utf8) else {
			XCTFail("Failed to encode id into data")
			return
		}

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypeTemporaryCulturalEvent,
			description: "Concert",
			address: "Concert Hall",
			startDate: Date(timeIntervalSince1970: 1629032400),
			endDate: Date(timeIntervalSince1970: 1629032700),
			defaultCheckInLengthInMinutes: 37,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey
		)

		let onPrimaryButtonTapExpectation = expectation(description: "onPrimaryButtonTap called")

		let viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: traceLocation,
			onPrimaryButtonTap: { checkin in
				XCTAssertEqual(checkin.traceLocationId, id)
				XCTAssertEqual(checkin.traceLocationIdHash, traceLocation.idHash)
				XCTAssertEqual(checkin.traceLocationVersion, 1)
				XCTAssertEqual(checkin.traceLocationType, .locationTypeTemporaryCulturalEvent)
				XCTAssertEqual(checkin.traceLocationDescription, "Concert")
				XCTAssertEqual(checkin.traceLocationAddress, "Concert Hall")
				XCTAssertEqual(checkin.traceLocationStartDate, Date(timeIntervalSince1970: 1629032400))
				XCTAssertEqual(checkin.traceLocationEndDate, Date(timeIntervalSince1970: 1629032700))
				XCTAssertEqual(checkin.traceLocationDefaultCheckInLengthInMinutes, 37)
				XCTAssertEqual(checkin.cryptographicSeed, cryptographicSeed)
				XCTAssertEqual(checkin.cnPublicKey, cnPublicKey)
				XCTAssertEqual(
					checkin.checkinStartDate,
					Date(timeIntervalSince1970: 1629032400)
				)
				// endDate - startDate = 5 min is rounded up to 15 min
				XCTAssertEqual(
					checkin.checkinEndDate,
					Date(timeIntervalSince1970: 1629032400).addingTimeInterval(15 * 60)
				)
				XCTAssertFalse(checkin.checkinCompleted)
				XCTAssertFalse(checkin.createJournalEntry)
				XCTAssertFalse(checkin.checkinSubmitted)

				onPrimaryButtonTapExpectation.fulfill()
			}
		)

		viewModel.createCheckin()

		waitForExpectations(timeout: .short)
	}

	func testCreateCheckin_LocationWithStartDateInTheFutureWithoutDefaultCheckinLength() {
		guard let id = "TraceLocationID".data(using: .utf8),
			  let cryptographicSeed = "CryptographicSeed".data(using: .utf8),
			  let cnPublicKey = "PublicKey".data(using: .utf8) else {
			XCTFail("Failed to encode id into data")
			return
		}

		let startDate = Date(timeIntervalSinceNow: 1000)
		let endDate = Date(timeIntervalSinceNow: 4900)

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypeTemporaryCulturalEvent,
			description: "Concert",
			address: "Concert Hall",
			startDate: startDate,
			endDate: endDate,
			// 0 should be handled as not set
			defaultCheckInLengthInMinutes: 0,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey
		)

		let onPrimaryButtonTapExpectation = expectation(description: "onPrimaryButtonTap called")

		let viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: traceLocation,
			onPrimaryButtonTap: { checkin in
				XCTAssertEqual(checkin.traceLocationId, id)
				XCTAssertEqual(checkin.traceLocationIdHash, traceLocation.idHash)
				XCTAssertEqual(checkin.traceLocationVersion, 1)
				XCTAssertEqual(checkin.traceLocationType, .locationTypeTemporaryCulturalEvent)
				XCTAssertEqual(checkin.traceLocationDescription, "Concert")
				XCTAssertEqual(checkin.traceLocationAddress, "Concert Hall")
				XCTAssertEqual(checkin.traceLocationStartDate, startDate)
				XCTAssertEqual(checkin.traceLocationEndDate, endDate)
				XCTAssertEqual(checkin.traceLocationDefaultCheckInLengthInMinutes, 0)
				XCTAssertEqual(checkin.cryptographicSeed, cryptographicSeed)
				XCTAssertEqual(checkin.cnPublicKey, cnPublicKey)
				XCTAssertEqual(
					checkin.checkinStartDate.timeIntervalSince1970,
					Date().timeIntervalSince1970,
					accuracy: 10
				)
				// endDate - startDate = 65 min is rounded up to 75 min
				XCTAssertEqual(
					checkin.checkinEndDate.timeIntervalSince1970,
					Date(timeIntervalSinceNow: 75 * 60).timeIntervalSince1970,
					accuracy: 10
				)
				XCTAssertFalse(checkin.checkinCompleted)
				XCTAssertFalse(checkin.createJournalEntry)
				XCTAssertFalse(checkin.checkinSubmitted)

				onPrimaryButtonTapExpectation.fulfill()
			}
		)

		viewModel.createCheckin()

		waitForExpectations(timeout: .short)
	}

}
