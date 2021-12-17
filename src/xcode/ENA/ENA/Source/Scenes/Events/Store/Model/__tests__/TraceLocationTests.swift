////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationTests: CWATestCase {

	// This test is aligned with a test on the backend side. To ensure that the hashing algorithm returns the same value. Backend test: https://github.com/corona-warn-app/cwa-server/pull/1302/commits/5ce7d27a74fbf4f2ed560772f97ac17e2189ad33#diff-756ac98ac622ebe84967e1057450c3042e440b3c13c1378f5ec592fe5e662983R141-R150

	func test_Given_AnId_When_HashingTheId_Then_CorrectHashIsReturned() {
		let locationId = "afa27b44d43b02a9fea41d13cedc2e4016cfcf87c5dbf990e593669aa8ce286d"
		let data = locationId.dataWithHexString()
		let traceLocation = createMockTraceLocation(id: data)

		guard let idHash = traceLocation.idHash else {
			XCTFail("Could not create id hash.")
			return
		}

		let idHashString = idHash.hexEncodedString().lowercased()

		XCTAssertEqual(idHashString, "0f37dac11d1b8118ea0b44303400faa5e3b876da9d758058b5ff7dc2e5da8230")
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateNilWithDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23
		)

		// defaultCheckInLengthInMinutes of 23 is rounded up to 30
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 30)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateZeroWithDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 0),
			endDate: Date(timeIntervalSince1970: 0),
			defaultCheckInLengthInMinutes: 23
		)

		// defaultCheckInLengthInMinutes of 23 is rounded up to 30
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 30)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1629032400),
			endDate: Date(timeIntervalSince1970: 1629032700),
			defaultCheckInLengthInMinutes: 37
		)

		// defaultCheckInLengthInMinutes of 37 is rounded up to 45
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 45)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateWithDefaultCheckinLengthZero() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1000),
			endDate: Date(timeIntervalSince1970: 4900),
			defaultCheckInLengthInMinutes: 0
		)

		// endDate - startDate = 65 min is rounded up to 75 min
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 75)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateWithDefaultCheckinLengthNil() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1000),
			endDate: Date(timeIntervalSince1970: 4900),
			defaultCheckInLengthInMinutes: nil
		)

		// endDate - startDate = 65 min is rounded up to 75 min
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 75)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLengthZero() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 0),
			endDate: Date(timeIntervalSince1970: 0),
			defaultCheckInLengthInMinutes: 0
		)

		// fallback length is 15 min
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 15)
	}

	func testSuggestedCheckoutLengthInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLengthNil() {
		let traceLocation: TraceLocation = .mock(
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: nil
		)

		// fallback length is 15 min
		XCTAssertEqual(traceLocation.suggestedCheckoutLengthInMinutes, 15)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateNilWithDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23
		)

		// defaultCheckInLengthInMinutes of 23 is rounded up to 30
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 30)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateZeroWithDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 0),
			endDate: Date(timeIntervalSince1970: 0),
			defaultCheckInLengthInMinutes: 23
		)

		// defaultCheckInLengthInMinutes of 23 is rounded up to 30
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 30)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1629032400),
			endDate: Date(timeIntervalSince1970: 1629032700),
			defaultCheckInLengthInMinutes: 37
		)

		// endDate - startDate = 5 min is rounded up to 15 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 15)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartDateWithoutDefaultCheckinLength() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1000),
			endDate: Date(timeIntervalSince1970: 4900),
			defaultCheckInLengthInMinutes: 37
		)

		// endDate - startDate = 65 min is rounded up to 75 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 75)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateWithDefaultCheckinLengthZero() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1000),
			endDate: Date(timeIntervalSince1970: 4900),
			defaultCheckInLengthInMinutes: 0
		)

		// endDate - startDate = 65 min is rounded up to 75 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 75)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateWithDefaultCheckinLengthNil() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 1000),
			endDate: Date(timeIntervalSince1970: 4900),
			defaultCheckInLengthInMinutes: nil
		)

		// endDate - startDate = 65 min is rounded up to 75 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 75)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLengthZero() {
		let traceLocation: TraceLocation = .mock(
			startDate: Date(timeIntervalSince1970: 0),
			endDate: Date(timeIntervalSince1970: 0),
			defaultCheckInLengthInMinutes: 0
		)

		// fallback length is 120 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 120)
	}

	func testSuggestedOnBehalfWarningDurationInMinutes_LocationWithStartAndEndDateAndDefaultCheckinLengthNil() {
		let traceLocation: TraceLocation = .mock(
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: nil
		)

		// fallback length is 120 min
		XCTAssertEqual(traceLocation.suggestedOnBehalfWarningDurationInMinutes, 120)
	}

	// MARK: - Private

	private func createMockTraceLocation(id: Data) -> TraceLocation {
		TraceLocation(
			id: id,
			version: 0,
			type: .locationTypePermanentCraft,
			description: "Some Description",
			address: "Some Address",
			startDate: Date(),
			endDate: Date(),
			defaultCheckInLengthInMinutes: 15,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)
	}
}

private extension Data {
	func hexEncodedString() -> String {
		let format = "%02hhx"
		return self.map { String(format: format, $0) }.joined()
	}
}
