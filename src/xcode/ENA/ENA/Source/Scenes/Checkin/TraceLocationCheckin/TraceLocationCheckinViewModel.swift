////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TraceLocationCheckinViewModel {

	// MARK: - Init
	
	init(_ traceLocation: TraceLocation, eventStore: EventStoringProviding, store: Store) {
		self.store = store
		self.eventStore = eventStore
		self.traceLocation = traceLocation
		#if !RELEASE
		// save the trace location for dev menu to see every data.
		store.recentTraceLocationCheckedInto = DMRecentTraceLocationCheckedInto(
			description: traceLocation.description,
			id: traceLocation.id,
			date: Date()
		)
		#endif
		self.locationType = traceLocation.type.title
		self.locationAddress = traceLocation.address
		self.locationDescription = traceLocation.description
		self.shouldSaveToContactJournal = store.shouldAddCheckinToContactDiaryByDefault
		// max duration in the picker is 23:45
		let maxDurationInMinutes = (23 * 60) + 45
		self.duration = TimeInterval(min(traceLocation.suggestedCheckoutLength, maxDurationInMinutes) * 60)
	}
	
	// MARK: - Internal

	enum TraceLocationDateStatus {
		case notStarted
		case inProgress
		case ended
	}

	let locationType: String
	let locationDescription: String
	let locationAddress: String

	var shouldSaveToContactJournal: Bool

	@OpenCombine.Published var duration: TimeInterval

	var pickerButtonTitle: String {
		guard let durationString = durationFormatter.string(from: duration) else {
			Log.error("Failed to convert duration to string")
			return ""
		}
		return String(format: AppStrings.Checkins.Details.hoursShortVersion, durationString)
	}

	var pickerButtonAccessibilityLabel: String {
		let components = Calendar.utcCalendar.dateComponents([.hour, .minute], from: Date(timeIntervalSinceReferenceDate: duration))
		guard let accessibilityLabel = DateComponentsFormatter.localizedString(from: components, unitsStyle: .spellOut) else {
			return ""
		}
		return accessibilityLabel
	}

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
		guard let date = traceLocation.startDate else {
			return ""
		}
		return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
	}

	var formattedStartTimeString: String {
		guard let date = traceLocation.startDate else {
			return ""
		}
		return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
	}

	func saveCheckinToDatabase() {
		let checkinStartDate = Date()
		guard let checkinEndDate = Calendar.current.date(byAdding: .second, value: Int(duration), to: checkinStartDate),
			  let idHash = traceLocation.idHash else {
			Log.warning("checkinEndDate is nill", log: .checkin)
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
			createJournalEntry: shouldSaveToContactJournal,
			checkinSubmitted: false
		)

		store.shouldAddCheckinToContactDiaryByDefault = shouldSaveToContactJournal
		eventStore.createCheckin(checkin)
	}

	// MARK: - Private
	
	private let traceLocation: TraceLocation
	private let eventStore: EventStoringProviding
	private let store: Store

	private lazy var durationFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.hour, .minute]
		formatter.zeroFormattingBehavior = .default
		formatter.zeroFormattingBehavior = .pad
		return formatter
	}()

}
