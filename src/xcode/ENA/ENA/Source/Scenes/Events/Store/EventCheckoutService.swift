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
		let completedCheckin = checkin.completedCheckin()
		eventStore.updateCheckin(completedCheckin)

		if completedCheckin.createJournalEntry {
			createJournalEntry(of: completedCheckin)
		}

		if showNotification {
			triggerNotificationForCheckout(of: completedCheckin)
		}
	}

	func checkoutOverdueCheckins() {
		let overdueCheckins = eventStore.checkinsPublisher.value.filter {
			($0.checkinEndDate < Date())
		}

		overdueCheckins.forEach {
			let completedCheckin = $0.completedCheckin()
			eventStore.updateCheckin(completedCheckin)

			if completedCheckin.createJournalEntry {
				createJournalEntry(of: completedCheckin)
			}

			triggerNotificationForCheckout(of: completedCheckin)
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
		content.title = AppStrings.Checkout.notificationTitle
		content.body = AppStrings.Checkout.notificationBody
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
	func completedCheckin() -> Checkin {
		Checkin(
			id: self.id,
			traceLocationGUID: self.traceLocationGUID,
			traceLocationGUIDHash: self.traceLocationGUIDHash,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: self.traceLocationSignature,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: self.checkinEndDate,
			checkinCompleted: true,
			createJournalEntry: self.createJournalEntry)
	}
}
