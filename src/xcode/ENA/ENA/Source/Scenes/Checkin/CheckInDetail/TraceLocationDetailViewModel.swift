////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationDetailViewModel {

	// MARK: - Init
	
	init(_ traceLocation: TraceLocation) {
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
	@OpenCombine.Published var pickerButtonTitle: String?

	var shouldSaveToContactJournal = true

	func pickerView(didSelectRow numberOfMinutes: Int) {
		selectedDurationInMinutes = numberOfMinutes
		let components = numberOfMinutes.quotientAndRemainder(dividingBy: 60)
		let date = Calendar.current.date(bySettingHour: components.quotient, minute: components.remainder, second: 0, of: Date())
		if let hour = getFormattedHourString(date) {
			pickerButtonTitle = hour + " " + AppStrings.Checkins.Details.hoursShortVersion
		}
	}
		
	func setupView() {
		descriptionLabelTitle = traceLocation.description
		addressLabelTitle = traceLocation.address
		initialDuration = selectedDurationInMinutes
	}

	func getTraceLocationStatus() -> TraceLocationDateStatus? {
		guard let startDate = traceLocation.startDate,
			  let endDate = traceLocation.endDate else {
			return nil
		}
		if startDate > Date() {
			return .notStarted
		} else if endDate < Date() {
			return .ended
		} else {
			return .inProgress
		}
	}
	
	func getFormattedString(for component: Calendar.Component) -> String? {
		switch component {
		case .day:
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.locale = Locale.current
			return dateFormatter.string(from: traceLocation.startDate ?? Date())
		case .hour:
			return getFormattedHourString(traceLocation.startDate)
		default:
			return nil
		}
	}
	
	func getFormattedHourString(_ date: Date?) -> String? {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad
		let components = Calendar.current.dateComponents([.hour, .minute], from: date ?? Date())
		return dateComponentsFormatter.string(from: components)

	}
	
	func saveCheckinToDatabase() {
//		let startDate = Date()
//		let endDate = Calendar.current.date(byAdding: .minute, value: selectedDurationInMinutes, to: startDate)
//
//		let checkin: Checkin = Checkin(
//			id: 0,
//			traceLocationGUID: traceLocation.guid,
//			traceLocationGUIDHash: Data(),
//			traceLocationVersion: traceLocation.version,
//			traceLocationType: traceLocation.type,
//			traceLocationDescription: traceLocation.description,
//			traceLocationAddress: traceLocation.address,
//			traceLocationStartDate: traceLocation.startDate,
//			traceLocationEndDate: traceLocation.endDate,
//			traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
//			traceLocationSignature: traceLocation.signature,
//			checkinStartDate: Date(),
//			checkinEndDate: endDate ?? Date(),
//			checkinCompleted: false,
//			createJournalEntry: shouldSaveToContactJournal
//		)

		// eventStore.createCheckin(checkin)
	}

	// MARK: - Private
	
	private var selectedDurationInMinutes: Int
	private let traceLocation: TraceLocation
}

enum TraceLocationDateStatus {
	case notStarted
	case inProgress
	case ended
}
