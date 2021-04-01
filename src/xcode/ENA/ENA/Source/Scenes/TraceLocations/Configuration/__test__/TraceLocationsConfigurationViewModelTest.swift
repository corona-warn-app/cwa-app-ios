//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class TraceLocationsConfigurationViewModelTest: XCTestCase {

	func testInitialValuesForNewTemporaryTraceLocation() {
		for traceLocationType in TraceLocationType.temporaryTypes {
			let viewModel = TraceLocationConfigurationViewModel(
				mode: .new(traceLocationType),
				eventStore: MockEventStore()
			)

			guard let startDate = viewModel.startDate, let endDate = viewModel.endDate else {
				XCTFail("Start and end date must be set on temporary trace locations")
				continue
			}

			XCTAssertTrue(viewModel.startDatePickerIsHidden)
			XCTAssertTrue(viewModel.endDatePickerIsHidden)

			XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
			XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))

			XCTAssertTrue(viewModel.temporaryDefaultLengthPickerIsHidden)
			XCTAssertFalse(viewModel.temporaryDefaultLengthSwitchIsOn)

			XCTAssertFalse(viewModel.primaryButtonIsEnabled)

			XCTAssertEqual(viewModel.description, "")
			XCTAssertEqual(viewModel.address, "")

			XCTAssertEqual(
				startDate.timeIntervalSinceReferenceDate,
				Date().timeIntervalSinceReferenceDate,
				accuracy: 10
			)

			XCTAssertEqual(
				endDate.timeIntervalSinceReferenceDate,
				Date().timeIntervalSinceReferenceDate,
				accuracy: 10
			)

			XCTAssertNil(viewModel.defaultCheckInLengthInMinutes)

			XCTAssertNotNil(viewModel.formattedStartDate)
			XCTAssertNotNil(viewModel.formattedEndDate)
			XCTAssertNil(viewModel.formattedDefaultCheckInLength)

			XCTAssertEqual(viewModel.traceLocationTypeTitle, traceLocationType.title)
			XCTAssertFalse(viewModel.temporarySettingsContainerIsHidden)
			XCTAssertTrue(viewModel.permanentSettingsContainerIsHidden)
		}
	}

	func testInitialValuesForNewPermanentTraceLocation() {
		for traceLocationType in TraceLocationType.permanentTypes {
			let viewModel = TraceLocationConfigurationViewModel(
				mode: .new(traceLocationType),
				eventStore: MockEventStore()
			)

			XCTAssertTrue(viewModel.startDatePickerIsHidden)
			XCTAssertTrue(viewModel.endDatePickerIsHidden)

			XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
			XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))

			XCTAssertTrue(viewModel.permanentDefaultLengthPickerIsHidden)
			XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textPrimary1))

			XCTAssertFalse(viewModel.primaryButtonIsEnabled)

			XCTAssertEqual(viewModel.description, "")
			XCTAssertEqual(viewModel.address, "")
			XCTAssertNil(viewModel.startDate)
			XCTAssertNil(viewModel.endDate)
			XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, 15)

			XCTAssertNil(viewModel.formattedStartDate)
			XCTAssertNil(viewModel.formattedEndDate)
			XCTAssertNotNil(viewModel.formattedDefaultCheckInLength)

			XCTAssertEqual(viewModel.traceLocationTypeTitle, traceLocationType.title)
			XCTAssertTrue(viewModel.temporarySettingsContainerIsHidden)
			XCTAssertFalse(viewModel.permanentSettingsContainerIsHidden)
		}
	}

	func testInitialValuesForDuplicatedTemporaryTraceLocation() {
		let traceLocation = TraceLocation.mock(
			type: .locationTypeTemporaryOther,
			description: "CWA Fan Meetup",
			address: "111 Internet Highway",
			startDate: Date(timeIntervalSinceReferenceDate: 12345678),
			endDate: Date(timeIntervalSinceReferenceDate: 23456789),
			defaultCheckInLengthInMinutes: 37
		)

		let viewModel = TraceLocationConfigurationViewModel(
			mode: .duplicate(traceLocation),
			eventStore: MockEventStore()
		)

		XCTAssertTrue(viewModel.startDatePickerIsHidden)
		XCTAssertTrue(viewModel.endDatePickerIsHidden)

		XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))

		XCTAssertFalse(viewModel.temporaryDefaultLengthPickerIsHidden)
		XCTAssertTrue(viewModel.temporaryDefaultLengthSwitchIsOn)

		XCTAssertTrue(viewModel.primaryButtonIsEnabled)

		XCTAssertEqual(viewModel.description, traceLocation.description)
		XCTAssertEqual(viewModel.address, traceLocation.address)
		XCTAssertEqual(viewModel.startDate, traceLocation.startDate)
		XCTAssertEqual(viewModel.endDate, traceLocation.endDate)
		XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, traceLocation.defaultCheckInLengthInMinutes)

		XCTAssertNotNil(viewModel.formattedStartDate)
		XCTAssertNotNil(viewModel.formattedEndDate)
		XCTAssertNotNil(viewModel.formattedDefaultCheckInLength)

		XCTAssertEqual(viewModel.traceLocationTypeTitle, traceLocation.type.title)
		XCTAssertFalse(viewModel.temporarySettingsContainerIsHidden)
		XCTAssertTrue(viewModel.permanentSettingsContainerIsHidden)
	}

	func testInitialValuesForDuplicatedPermanentTraceLocation() {
		let traceLocation = TraceLocation.mock(
			type: .locationTypePermanentOther,
			description: "CWA Fan Shop",
			address: "111 Internet Highway",
			startDate: nil,
			endDate: nil,
			defaultCheckInLengthInMinutes: 18
		)

		let viewModel = TraceLocationConfigurationViewModel(
			mode: .duplicate(traceLocation),
			eventStore: MockEventStore()
		)

		XCTAssertTrue(viewModel.startDatePickerIsHidden)
		XCTAssertTrue(viewModel.endDatePickerIsHidden)

		XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))

		XCTAssertTrue(viewModel.permanentDefaultLengthPickerIsHidden)
		XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textPrimary1))

		XCTAssertTrue(viewModel.primaryButtonIsEnabled)

		XCTAssertEqual(viewModel.description, traceLocation.description)
		XCTAssertEqual(viewModel.address, traceLocation.address)
		XCTAssertNil(viewModel.startDate)
		XCTAssertNil(viewModel.endDate)
		XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, traceLocation.defaultCheckInLengthInMinutes)

		XCTAssertNil(viewModel.formattedStartDate)
		XCTAssertNil(viewModel.formattedEndDate)
		XCTAssertNotNil(viewModel.formattedDefaultCheckInLength)

		XCTAssertEqual(viewModel.traceLocationTypeTitle, traceLocation.type.title)
		XCTAssertTrue(viewModel.temporarySettingsContainerIsHidden)
		XCTAssertFalse(viewModel.permanentSettingsContainerIsHidden)
	}

	func testDefaultDefaultCheckInLengthTimeInterval() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeUnspecified),
			eventStore: MockEventStore()
		)

		XCTAssertEqual(viewModel.defaultDefaultCheckInLengthTimeInterval, 900)
	}

	func testHeaderTapped() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: MockEventStore()
		)

		viewModel.startDateHeaderTapped()
		checkOnlyStartDatePickerIsVisible(on: viewModel)

		viewModel.startDateHeaderTapped()
		checkNoDatePickerIsVisible(on: viewModel)

		viewModel.endDateHeaderTapped()
		checkOnlyEndDatePickerIsVisible(on: viewModel)

		viewModel.endDateHeaderTapped()
		checkNoDatePickerIsVisible(on: viewModel)

		viewModel.startDateHeaderTapped()
		checkOnlyStartDatePickerIsVisible(on: viewModel)

		viewModel.endDateHeaderTapped()
		checkOnlyEndDatePickerIsVisible(on: viewModel)

		viewModel.collapseAllSections()
		checkNoDatePickerIsVisible(on: viewModel)

		viewModel.startDateHeaderTapped()
		checkOnlyStartDatePickerIsVisible(on: viewModel)

		viewModel.collapseAllSections()
		checkNoDatePickerIsVisible(on: viewModel)
	}

	func testTemporaryDefaultLengthHeaderTapped() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: MockEventStore()
		)

		viewModel.temporaryDefaultLengthHeaderTapped()

		XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, 15)
		XCTAssertNotNil(viewModel.formattedDefaultCheckInLength)
		XCTAssertFalse(viewModel.temporaryDefaultLengthPickerIsHidden)
		XCTAssertTrue(viewModel.temporaryDefaultLengthSwitchIsOn)

		viewModel.temporaryDefaultLengthHeaderTapped()

		XCTAssertNil(viewModel.defaultCheckInLengthInMinutes)
		XCTAssertNil(viewModel.formattedDefaultCheckInLength)
		XCTAssertTrue(viewModel.temporaryDefaultLengthPickerIsHidden)
		XCTAssertFalse(viewModel.temporaryDefaultLengthSwitchIsOn)
	}

	func testTemporaryDefaultLengthSwitchSet() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: MockEventStore()
		)

		viewModel.temporaryDefaultLengthSwitchSet(to: true)

		XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, 15)
		XCTAssertNotNil(viewModel.formattedDefaultCheckInLength)
		XCTAssertFalse(viewModel.temporaryDefaultLengthPickerIsHidden)
		XCTAssertTrue(viewModel.temporaryDefaultLengthSwitchIsOn)

		viewModel.temporaryDefaultLengthSwitchSet(to: false)

		XCTAssertNil(viewModel.defaultCheckInLengthInMinutes)
		XCTAssertNil(viewModel.formattedDefaultCheckInLength)
		XCTAssertTrue(viewModel.temporaryDefaultLengthPickerIsHidden)
		XCTAssertFalse(viewModel.temporaryDefaultLengthSwitchIsOn)
	}

	func testPermanentDefaultLengthHeaderTapped() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypePermanentOther),
			eventStore: MockEventStore()
		)

		viewModel.permanentDefaultLengthHeaderTapped()

		XCTAssertFalse(viewModel.permanentDefaultLengthPickerIsHidden)
		XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textTint))

		viewModel.permanentDefaultLengthHeaderTapped()

		XCTAssertTrue(viewModel.permanentDefaultLengthPickerIsHidden)
		XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textPrimary1))

		viewModel.permanentDefaultLengthHeaderTapped()

		XCTAssertFalse(viewModel.permanentDefaultLengthPickerIsHidden)
		XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textTint))

		viewModel.collapseAllSections()

		XCTAssertTrue(viewModel.permanentDefaultLengthPickerIsHidden)
		XCTAssertEqual(viewModel.permanentDefaultLengthValueTextColor, .enaColor(for: .textPrimary1))
	}

	func testDefaultCheckinLengthValueChanged() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: MockEventStore()
		)

		viewModel.defaultCheckinLengthValueChanged(to: 660)

		XCTAssertEqual(viewModel.defaultCheckInLengthInMinutes, 11)
	}

	func testUpdateTextFields() {
		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: MockEventStore()
		)

		XCTAssertEqual(viewModel.description, "")
		XCTAssertEqual(viewModel.address, "")
		XCTAssertFalse(viewModel.primaryButtonIsEnabled)

		viewModel.update(description: "d")

		XCTAssertEqual(viewModel.description, "d")
		XCTAssertEqual(viewModel.address, "")
		XCTAssertFalse(viewModel.primaryButtonIsEnabled)

		viewModel.update(address: "a")

		XCTAssertEqual(viewModel.description, "d")
		XCTAssertEqual(viewModel.address, "a")
		XCTAssertTrue(viewModel.primaryButtonIsEnabled)

		viewModel.update(address: "")

		XCTAssertEqual(viewModel.description, "d")
		XCTAssertEqual(viewModel.address, "")
		XCTAssertFalse(viewModel.primaryButtonIsEnabled)

		viewModel.update(description: "")
		viewModel.update(address: "a")

		XCTAssertEqual(viewModel.description, "")
		XCTAssertEqual(viewModel.address, "a")
		XCTAssertFalse(viewModel.primaryButtonIsEnabled)

		viewModel.update(description: "d")

		XCTAssertEqual(viewModel.description, "d")
		XCTAssertEqual(viewModel.address, "a")
		XCTAssertTrue(viewModel.primaryButtonIsEnabled)
	}

	func testSaving() throws {
		let eventStore = MockEventStore()

		let viewModel = TraceLocationConfigurationViewModel(
			mode: .new(.locationTypeTemporaryOther),
			eventStore: eventStore
		)

		XCTAssertEqual(eventStore.traceLocationsPublisher.value.count, 0)

		try viewModel.save()

		XCTAssertEqual(eventStore.traceLocationsPublisher.value.count, 1)
	}

	// MARK: - Private

	private func checkOnlyStartDatePickerIsVisible(on viewModel: TraceLocationConfigurationViewModel) {
		XCTAssertFalse(viewModel.startDatePickerIsHidden)
		XCTAssertTrue(viewModel.endDatePickerIsHidden)
		XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textTint))
		XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))
	}

	private func checkOnlyEndDatePickerIsVisible(on viewModel: TraceLocationConfigurationViewModel) {
		XCTAssertTrue(viewModel.startDatePickerIsHidden)
		XCTAssertFalse(viewModel.endDatePickerIsHidden)
		XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textTint))
	}

	private func checkNoDatePickerIsVisible(on viewModel: TraceLocationConfigurationViewModel) {
		XCTAssertTrue(viewModel.startDatePickerIsHidden)
		XCTAssertTrue(viewModel.endDatePickerIsHidden)
		XCTAssertEqual(viewModel.startDateValueTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.endDateValueTextColor, .enaColor(for: .textPrimary1))
	}

}
