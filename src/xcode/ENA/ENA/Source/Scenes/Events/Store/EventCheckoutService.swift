////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

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

	func checkout(checkin: Checkin, manually: Bool) {
		let completedCheckin = checkin.completedCheckin(manually: manually)
		eventStore.updateCheckin(completedCheckin)

		if completedCheckin.createJournalEntry {
			createJournalEntry(of: completedCheckin)
		}

		if !manually {
			triggerNotificationForCheckout(of: completedCheckin)
		}
	}

	func checkoutOverdueCheckins() {
		let overdueCheckins = eventStore.checkinsPublisher.value.filter {
			($0.checkinEndDate < Date())
		}

		overdueCheckins.forEach {
			self.checkout(checkin: $0, manually: false)
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
			$0.traceLocationId == checkin.traceLocationId
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
				traceLocationId: checkin.traceLocationId
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
	func completedCheckin(manually: Bool) -> Checkin {
		Checkin(
			id: self.id,
			traceLocationId: self.traceLocationId,
			traceLocationIdHash: self.traceLocationIdHash,
			traceLocationVersion: self.traceLocationVersion,
			traceLocationType: self.traceLocationType,
			traceLocationDescription: self.traceLocationDescription,
			traceLocationAddress: self.traceLocationAddress,
			traceLocationStartDate: self.traceLocationStartDate,
			traceLocationEndDate: self.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: self.traceLocationDefaultCheckInLengthInMinutes,
			cryptographicSeed: self.cryptographicSeed,
			cnPublicKey: self.cnPublicKey,
			checkinStartDate: self.checkinStartDate,
			checkinEndDate: manually ? Date() : self.checkinEndDate,
			checkinCompleted: true,
			createJournalEntry: self.createJournalEntry)
	}
}
