////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationDetailViewModel {

	// MARK: - Init
	
	init(_ traceLocation: TraceLocation, eventStore: EventStoringProviding, store: Store) {
		self.store = store
		self.eventStore = eventStore
		self.traceLocation = traceLocation
		self.locationAddress = traceLocation.address
		self.locationDescription = traceLocation.description
		self.shouldSaveToContactJournal = store.shouldAddCheckinToContactDiarybyDefault
		
		if let defaultDuration = traceLocation.defaultCheckInLengthInMinutes {
			self.selectedDurationInMinutes = defaultDuration
		} else {
			let eventDuration = Calendar.current.dateComponents(
				[.minute],
				from: traceLocation.startDate ?? Date(),
				to: traceLocation.endDate ?? Date()
			).minute
			// the 0 should not be possible since we expect either the defaultCheckInLengthInMinutes or the start and end dates to be available always
			self.selectedDurationInMinutes = eventDuration ?? 0
		}
	}
	
	// MARK: - Internal
		
	@OpenCombine.Published var pickerButtonTitle: String?

	let locationDescription: String
	let locationAddress: String
	var selectedDurationInMinutes: Int
	var shouldSaveToContactJournal: Bool
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
	var formattedStartDateString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter.string(from: traceLocation.startDate ?? Date())
	}
	var formattedStartTimeString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
		dateFormatter.dateStyle = .none
		return dateFormatter.string(from: traceLocation.startDate ?? Date())
	}
	
	enum TraceLocationDateStatus {
		case notStarted
		case inProgress
		case ended
	}

	func pickerView(didSelectRow numberOfMinutes: Int) {
		selectedDurationInMinutes = numberOfMinutes
		let components = numberOfMinutes.quotientAndRemainder(dividingBy: 60)
		let date = Calendar.current.date(bySettingHour: components.quotient, minute: components.remainder, second: 0, of: Date())
		if let hour = formattedHourString(date) {
			pickerButtonTitle = String(format: AppStrings.Checkins.Details.hoursShortVersion, hour)
		}
	}
	
	func saveCheckinToDatabase() {
		let checkinStartDate = Date()
		guard let checkinEndDate = Calendar.current.date(byAdding: .minute, value: selectedDurationInMinutes, to: checkinStartDate) else {
			Log.warning("checkinEndDate is nill", log: .checkin)
			return
		}
		guard let guidHash = generateSHA256(traceLocation.guid) else {
			return
		}
		let checkin: Checkin = Checkin(
			id: 0,
			traceLocationGUID: traceLocation.guid,
			traceLocationGUIDHash: guidHash,
			traceLocationVersion: traceLocation.version,
			traceLocationType: traceLocation.type,
			traceLocationDescription: traceLocation.description,
			traceLocationAddress: traceLocation.address,
			traceLocationStartDate: traceLocation.startDate,
			traceLocationEndDate: traceLocation.endDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
			traceLocationSignature: traceLocation.signature,
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: false,
			createJournalEntry: shouldSaveToContactJournal
		)

		store.shouldAddCheckinToContactDiarybyDefault = shouldSaveToContactJournal
		 eventStore.createCheckin(checkin)
	}

	// MARK: - Private
	
	private let traceLocation: TraceLocation
	private let eventStore: EventStoringProviding
	private let store: Store
	
	private func formattedHourString(_ date: Date?) -> String? {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad
		let components = Calendar.current.dateComponents([.hour, .minute], from: date ?? Date())
		return dateComponentsFormatter.string(from: components)
	}
	
	private func generateSHA256(_ guid: String) -> Data? {
		let encoder = JSONEncoder()
		do {
			let guidData = try encoder.encode(guid)
			return guidData.sha256()
		} catch {
			Log.error("traceLocationGUID Encoding error", log: .checkin, error: error)
			return nil
		}
	}
}
