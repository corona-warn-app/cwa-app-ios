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
		self.shouldSaveToContactJournal = store.shouldAddCheckinToContactDiaryByDefault
		self.selectedDurationInMinutes = traceLocation.initialTimeForCheckout
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
		guard let idHash = traceLocation.guidHash else {
			return
		}
		
		let checkin: Checkin = Checkin(
			id: 0,
			traceLocationId: traceLocation.id,
			traceLocationIdHash: idHash,
			traceLocationVersion: traceLocation.version,
			traceLocationType: traceLocation.type,
			traceLocationDescription: traceLocation.description,
			traceLocationAddress: traceLocation.address,
			traceLocationStartDate: traceLocation.startDate,
			traceLocationEndDate: traceLocation.endDate,
			traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
			cryptographicSeed: traceLocation.cryptographicSeed,
			cnPublicKey: traceLocation.cnPublicKey,
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			checkinCompleted: false,
			createJournalEntry: shouldSaveToContactJournal
		)

		store.shouldAddCheckinToContactDiaryByDefault = shouldSaveToContactJournal
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
}
