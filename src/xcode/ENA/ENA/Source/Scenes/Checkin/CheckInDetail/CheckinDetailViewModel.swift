////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CheckinDetailViewModel {

	// MARK: - Init
	
	init(
		_ traceLocation: TraceLocation
	) {
		self.traceLocation = traceLocation
		
		if let defaultDuration = traceLocation.defaultCheckInLengthInMinutes {
			selectedDurationInMinutes = defaultDuration
		} else {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: traceLocation.startDate ?? Date(),
				to: traceLocation.endDate ?? Date()
			)
			// the 0 should not be possible since we expect either the defaultCheckInLengthInMinutes or the start and end dates to be available always
			selectedDurationInMinutes = eventDuration.minute ?? 0
		}
	}
	
	// MARK: - Internal
		
	@OpenCombine.Published var descriptionLabelTitle: String?
	@OpenCombine.Published var addressLabelTitle: String?
	@OpenCombine.Published var initialDuration: Int?
	
	var shouldSaveToContactJournal = true

	func pickerView(didSelectRow numberOfMinutes: Int) {
		selectedDurationInMinutes = numberOfMinutes
		
	}
		
	func setupView() {
		descriptionLabelTitle = traceLocation.description
		addressLabelTitle = traceLocation.address
		initialDuration = selectedDurationInMinutes
	}

	func saveCheckinToDatabase() {
		let startDate = Date()
		let endDate = Calendar.current.date(byAdding: .minute, value: selectedDurationInMinutes, to: startDate)

		let checkin = Checkin(
			id: 0,
			traceLocationGUID: traceLocation.guid,
			traceLocationVersion: traceLocation.version,
			traceLocationType: traceLocation.type,
			traceLocationDescription: traceLocation.description,
			traceLocationAddress: traceLocation.address,
			traceLocationStartDate: traceLocation.startDate,
			traceLocationEndDate: traceLocation.endDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
			traceLocationSignature: traceLocation.signature,
			checkinStartDate: Date(),
			checkinEndDate: endDate,
			targetCheckinEndDate: endDate,
			createJournalEntry: shouldSaveToContactJournal
		)
		// TO DO: SAVE to the store
	}

	// MARK: - Private
	
	private var selectedDurationInMinutes: Int
	private let traceLocation: TraceLocation
}
