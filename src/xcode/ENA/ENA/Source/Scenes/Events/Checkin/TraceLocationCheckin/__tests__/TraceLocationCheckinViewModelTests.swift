////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class TraceLocationCheckinViewModelTests: CWATestCase {

	private var subscriptions = Set<AnyCancellable>()
		
	func testTraceLocationCheckinViewModel_initialization_PropertiesAreCorrect() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let store = MockTestStore()
		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: store)
		
		XCTAssertEqual(sut.locationType, TraceLocationType.locationTypePermanentFoodService.title)
		XCTAssertEqual(sut.locationDescription?.string, "Los Pollos Hermanos")
		XCTAssertEqual(sut.locationAddress, "13 Main Street, Albuquerque")
		// Duration should be rounded up to 30
		XCTAssertEqual(sut.duration, 30 * 60)
		XCTAssertEqual(sut.shouldSaveToContactJournal, store.shouldAddCheckinToContactDiaryByDefault)
	}

	func testTraceLocationCheckinViewModel_initialization_suggestedCheckoutIsLessThanADay() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		guard let startDate = Calendar.utcCalendar.date(byAdding: .hour, value: 1, to: Date()),
			  let endDate = Calendar.utcCalendar.date(byAdding: .day, value: 2, to: Date()) else {
			XCTFail("Failed create start and end date")
			return
		}
		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: nil,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let store = MockTestStore()
		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: store)
		
		XCTAssertEqual(sut.locationType, TraceLocationType.locationTypePermanentFoodService.title)
		XCTAssertEqual(sut.locationDescription?.string, "Los Pollos Hermanos")
		XCTAssertEqual(sut.locationAddress, "13 Main Street, Albuquerque")
		// max checkout Duration should be clipped to 23:45 to match the picker
		XCTAssertEqual(sut.duration, ((23 * 60) + 45) * 60)
	}

    func testTraceLocationCheckinViewModel_EventStatus_EventWithNoStartAndEndDate() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())

		XCTAssertNil(sut.traceLocationStatus, "status should be nil as there is no start and end dates")
    }
	
	func testTraceLocationCheckinViewModel_EventStatus_EventNotStarted() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		guard let startDate = Calendar.utcCalendar.date(byAdding: .hour, value: 1, to: Date()),
			  let endDate = Calendar.utcCalendar.date(byAdding: .hour, value: 2, to: Date()) else {
			XCTFail("Failed create start and end date")
			return
		}
		
		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: nil,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())

		XCTAssertEqual(sut.traceLocationStatus, TraceLocationCheckinViewModel.TraceLocationDateStatus.notStarted)
	}
	
	func testTraceLocationCheckinViewModel_EventStatus_EventEnded() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		guard let startDate = Calendar.utcCalendar.date(byAdding: .hour, value: -2, to: Date()),
			  let endDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			XCTFail("Failed create start and end date")
			return
		}

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())

		XCTAssertEqual(sut.traceLocationStatus, TraceLocationCheckinViewModel.TraceLocationDateStatus.ended)
	}
	
	func testTraceLocationCheckinViewModel_EventStatus_EventInProgress() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		guard let startDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()),
			  let endDate = Calendar.utcCalendar.date(byAdding: .hour, value: 1, to: Date()) else {
			XCTFail("Failed create start and end date")
			return
		}

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())

		XCTAssertEqual(sut.traceLocationStatus, TraceLocationCheckinViewModel.TraceLocationDateStatus.inProgress)
	}
	
	func testTraceLocationCheckinViewModel_formattedStartDateString() {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		guard let startDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()),
			  let endDate = Calendar.utcCalendar.date(byAdding: .hour, value: 1, to: Date()) else {
			XCTFail("Failed create start and end date")
			return
		}

		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())

		// we need to test using the formatter because using hard coded strings will be wrong in other locals formatting
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		let expectedDate = dateFormatter.string(from: traceLocation.startDate ?? Date())
		XCTAssertEqual(sut.formattedStartDateString, expectedDate)
		
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short
		let expectedTime = dateFormatter.string(from: traceLocation.startDate ?? Date())
		XCTAssertEqual(sut.formattedStartTimeString, expectedTime)
	}
	
	func testTraceLocationCheckinViewModel_DidSelectDuration() throws {
		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		let traceLocation = TraceLocation(
			id: id,
			version: 1,
			type: .locationTypePermanentFoodService,
			description: "Los Pollos Hermanos",
			address: "13 Main Street, Albuquerque",
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 23,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)

		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: MockEventStore(), store: MockTestStore())
		
		let durationToBeSelected = 150
		sut.duration = TimeInterval(durationToBeSelected * 60)
		XCTAssertEqual(Int(sut.duration), durationToBeSelected * 60, "Selected duration should be reflected in the viewModel")
		
		// expected Button Title
		let selectedComponents = durationToBeSelected.quotientAndRemainder(dividingBy: 60)
		let date = Calendar.current.date(bySettingHour: selectedComponents.quotient, minute: selectedComponents.remainder, second: 0, of: Date())

		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad
		let components = Calendar.current.dateComponents([.hour, .minute], from: date ?? Date())
		let expectedDuration = try XCTUnwrap(dateComponentsFormatter.string(from: components))

		XCTAssertEqual(sut.pickerButtonTitle, String(format: AppStrings.Checkins.Details.hoursShortVersion, expectedDuration), "The title should be correctly formatted")
	}
	
	func testTraceLocationCheckinViewModel_SavingCheckin() throws {
		let currentDate = Date()

		guard let id = Data(base64Encoded: "Test") else {
			XCTFail("Failed to encode id into data")
			return
		}
		let version = 1
		let type: TraceLocationType = .locationTypePermanentFoodService
		let description = "Los Pollos Hermanos"
		let address = "13 Main Street, Albuquerque"
		let startDate = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -1, to: currentDate))
		let endDate = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: 1, to: currentDate))
		let defaultCheckInLengthInMinutes = 121
		let cryptographicSeed = "cryptographicSeed".data(using: .utf8) ?? Data()
		let cnPublicKey = "cnPublicKey".data(using: .utf8) ?? Data()
		
		let traceLocation = TraceLocation(
			id: id,
			version: version,
			type: type,
			description: description,
			address: address,
			startDate: startDate,
			endDate: endDate,
			defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
			cryptographicSeed: cryptographicSeed,
			cnPublicKey: cnPublicKey
		)

		let eventStore = MockEventStore()
		let sut = TraceLocationCheckinViewModel(traceLocation, eventStore: eventStore, store: MockTestStore())
		sut.shouldSaveToContactJournal = false
		sut.saveCheckinToDatabase()
		
		let checkinEndDate = try XCTUnwrap(Calendar.current.date(byAdding: .second, value: Int(sut.duration), to: currentDate))

		let sinkExpectation = expectation(description: "Sink is called once.")
		sinkExpectation.expectedFulfillmentCount = 1
		
		eventStore.checkinsPublisher
			.sink { checkins in
				XCTAssertEqual(checkins.count, 1)
				let checkin = checkins[0]
				XCTAssertEqual(checkin.traceLocationId, id)
				XCTAssertEqual(checkin.traceLocationIdHash, id.sha256())
				XCTAssertEqual(checkin.traceLocationVersion, version)
				XCTAssertEqual(checkin.traceLocationType, type)
				XCTAssertEqual(checkin.traceLocationDescription, description)
				XCTAssertEqual(checkin.traceLocationAddress, address)
				XCTAssertEqual(checkin.traceLocationDefaultCheckInLengthInMinutes, defaultCheckInLengthInMinutes)
				XCTAssertEqual(checkin.cryptographicSeed, cryptographicSeed)
				XCTAssertEqual(checkin.cnPublicKey, cnPublicKey)
				XCTAssertEqual(Int(checkin.checkinStartDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
				XCTAssertEqual(Int(checkin.checkinEndDate.timeIntervalSince1970), Int(checkinEndDate.timeIntervalSince1970))
				XCTAssertFalse(checkin.checkinCompleted)
				XCTAssertFalse(checkin.createJournalEntry)
				sinkExpectation.fulfill()
			}
			.store(in: &subscriptions)
		
		waitForExpectations(timeout: .medium)
	}
}
