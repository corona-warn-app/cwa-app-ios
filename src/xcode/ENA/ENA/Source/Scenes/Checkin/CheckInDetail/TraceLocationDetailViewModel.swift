////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationDetailViewModel {

	// MARK: - Init
	
	init(_ traceLocation: TraceLocation) {
		self.traceLocation = traceLocation
	}
	
	// MARK: - Internal
		
	@OpenCombine.Published var pickerButtonTitle: String?

	var selectedDurationInMinutes = 0
	var shouldSaveToContactJournal = true
	var traceLocationStatus: TraceLocationDateStatus? {
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
	
	var initialDuration: Int {
		if let defaultDuration = traceLocation.defaultCheckInLengthInMinutes {
			return defaultDuration
		} else {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: traceLocation.startDate ?? Date(),
				to: traceLocation.endDate ?? Date()
			)
			// the 0 should not be possible since we expect either the defaultCheckInLengthInMinutes or the start and end dates to be available always
			return eventDuration.minute ?? 0
		}
	}
	
	func setupViewModel() {
		selectedDurationInMinutes = initialDuration
	}
	func pickerView(didSelectRow numberOfMinutes: Int) {
		selectedDurationInMinutes = numberOfMinutes
		let components = numberOfMinutes.quotientAndRemainder(dividingBy: 60)
		let date = Calendar.current.date(bySettingHour: components.quotient, minute: components.remainder, second: 0, of: Date())
		if let hour = formattedHourString(date) {
			pickerButtonTitle = hour + " " + AppStrings.Checkins.Details.hoursShortVersion
		}
	}
	

	
	func formattedString(for component: Calendar.Component) -> String? {
		switch component {
		case .day:
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.locale = Locale.current
			return dateFormatter.string(from: traceLocation.startDate ?? Date())
		case .hour:
			return formattedHourString(traceLocation.startDate)
		default:
			return nil
		}
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
	
	private let traceLocation: TraceLocation
	
	private func formattedHourString(_ date: Date?) -> String? {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad
		let components = Calendar.current.dateComponents([.hour, .minute], from: date ?? Date())
		return dateComponentsFormatter.string(from: components)

	}
}

enum TraceLocationDateStatus {
	case notStarted
	case inProgress
	case ended
}
