////
// 🦠 Corona-Warn-App
//

import UIKit
import UserNotifications

final class EventCheckoutService {

	// MARK: - Init

	init(
		eventStore: EventStoringProviding,
		contactDiaryStore: DiaryStoringProviding,
		userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
	) {
		self.eventStore = eventStore
		self.contactDiaryStore = contactDiaryStore
		self.userNotificationCenter = userNotificationCenter

		registerToDidBecomeActiveNotification()
	}

	// MARK: - Internal

	func checkout(checkin: Checkin, showNotification: Bool) {
		let checkinEndDate = checkin.targetCheckinEndDate ?? Date()
		let updatedCheckin = checkin.updatedCheckin(with: checkinEndDate)
		eventStore.updateCheckin(updatedCheckin)

		if updatedCheckin.createJournalEntry {
			createJournalEntry(of: updatedCheckin)
		}

		if showNotification {
			triggerNotificationForCheckout(of: updatedCheckin)
		}
	}

	func checkoutOverdueCheckins() {
		let overdueCheckins = eventStore.checkinsPublisher.value.filter {
			$0.checkinEndDate == nil && ($0.targetCheckinEndDate ?? Date()) < Date()
		}
		overdueCheckins.forEach {
			let updatedCheckin = $0.updatedCheckin(with: $0.targetCheckinEndDate)
			eventStore.updateCheckin(updatedCheckin)

			if updatedCheckin.createJournalEntry {
				createJournalEntry(of: updatedCheckin)
			}

			triggerNotificationForCheckout(of: updatedCheckin)
		}
	}

	// MARK: - Private

	private let eventStore: EventStoringProviding
	private let contactDiaryStore: DiaryStoringProviding
	private let userNotificationCenter: UserNotificationCenter
	private lazy var shortDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()

	private func createJournalEntry(of checkin: Checkin) {
		let locations: [DiaryLocation] = contactDiaryStore.diaryDaysPublisher.value[0].entries.compactMap {
			if case let .location(location) = $0 {
				return location
			} else {
				return nil
			}
		}

		let checkinLocationExists = locations.contains {
			$0.traceLocationGUID == checkin.traceLocationGUID
		}

		if !checkinLocationExists {
			var locationNameElements = [String]()

			if !checkin.traceLocationDescription.isEmpty {
				locationNameElements.append(checkin.traceLocationDescription)
			}

			if !checkin.traceLocationAddress.isEmpty {
				locationNameElements.append(checkin.traceLocationAddress)
			}

			if let startDate = checkin.traceLocationStartDate {
				locationNameElements.append(shortDateFormatter.string(from: startDate))
			}

			if	let endDate = checkin.traceLocationEndDate {
				locationNameElements.append(shortDateFormatter.string(from: endDate))
			}

			let addLocationResult = contactDiaryStore.addLocation(
				name: locationNameElements.joined(separator: ", "),
				phoneNumber: "",
				emailAddress: "",
				traceLocationGUID: checkin.traceLocationGUID
			)

			guard case let .success(locationId) = addLocationResult else {
				return
			}

			let splittedCheckins = CheckinSplittingService().split(checkin)
			splittedCheckins.forEach { checkin in

				contactDiaryStore.addLocationVisit(
					locationId: locationId,
					date: ISO8601DateFormatter.contactDiaryFormatter.string(
						from: checkin.checkinStartDate
					),
					durationInMinutes: checkin.roundedDurationIn15mSteps,
					circumstances: "",
					checkinId: checkin.id
				)
			}
		}
	}

	private func triggerNotificationForCheckout(of checkin: Checkin) {
		userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(checkin.id)"])

		let content = UNMutableNotificationContent()
		content.title = "Sie wurden automatisch ausgecheckt."
		content.body = "Bitte passen Sie Ihre Aufenthaltsdauer gegebenfalls an."
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: "\(checkin.id)",
			content: content,
			trigger: nil // nil triggers right away.
		)

		userNotificationCenter.add(request) { error in
			if error != nil {
				Log.error("Checkout notification could not be scheduled.")
			}
		}
	}

	private func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		checkoutOverdueCheckins()
	}
}

private extension Checkin {
	func updatedCheckin(with checkinEndDate: Date?) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationGUID: self.traceLocationGUID,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: self.traceLocationSignature,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: checkinEndDate,
			targetCheckinEndDate: self.targetCheckinEndDate,
			createJournalEntry: self.createJournalEntry)
	}
}
