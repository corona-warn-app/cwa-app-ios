////
// 🦠 Corona-Warn-App
//

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
	}

	// MARK: - Internal

	func checkout(checkin: Checkin, showNotification: Bool) {
		let checkinEndDate = Date()
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
	private lazy var dateFormatter: DateFormatter = {
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
			var locationNameElements = [
				checkin.traceLocationDescription,
				checkin.traceLocationAddress
			]

			if let startDate = checkin.traceLocationStartDate {
				locationNameElements.append(dateFormatter.string(from: startDate))
			}

			if	let endDate = checkin.traceLocationEndDate {
				locationNameElements.append(dateFormatter.string(from: endDate))
			}

			contactDiaryStore.addLocation(
				name: locationNameElements.joined(separator: ", "),
				phoneNumber: "",
				emailAddress: "",
				traceLocationGUID: checkin.traceLocationGUID
			)
		}
	}

	private func triggerNotificationForCheckout(of checkin: Checkin) {
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
