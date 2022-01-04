////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

import UIKit
import UserNotifications
import OpenCombine

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

		registerToCheckinChanges()
		registerToDidBecomeActiveNotification()
	}

	// MARK: - Internal

	func checkoutOverdueCheckins() {
		Log.info("[EventCheckoutService] Checkout overdue checkins.", log: .checkin)

		let overdueCheckins = eventStore.checkinsPublisher.value.filter {
			$0.checkinEndDate <= Date() && !$0.checkinCompleted
		}

		overdueCheckins.forEach {
			self.checkout(checkin: $0, manually: false)
		}
	}

	func checkout(checkin: Checkin, manually: Bool) {
		Log.info("[EventCheckoutService] Checkout checkin with id: \(checkin.id), manually: \(manually)", log: .checkin)

		let checkinEndDate = manually ? Date() : checkin.checkinEndDate
		let completedCheckin = checkin.completedCheckin(checkinEndDate: checkinEndDate)
		eventStore.updateCheckin(completedCheckin)
	}

	// MARK: - Private

	private var subscriptions = [AnyCancellable]()
	private let eventStore: EventStoringProviding
	private let contactDiaryStore: DiaryStoringProviding
	private let userNotificationCenter: UserNotificationCenter
	private lazy var shortDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()
	private lazy var dateIntervalFormatter: DateIntervalFormatter = {
		let formatter = DateIntervalFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()

	private func registerToCheckinChanges() {
		Log.info("[EventCheckoutService] Register to checkin changes.", log: .checkin)

		eventStore.checkinsPublisher.sink { [weak self] checkins in
			Log.info("[EventCheckoutService] checkinsPublisher sink called", log: .checkin)

			// Cancel all notifications.
			// This will also cancel the deleted checkins, which are not part of the publishers value.
			// After that, trigger notifications for not completed checkins again.
			// This way, updated checkinEndDates will be taken into account.
			// For completed checkins (checked out) just create journal entries, don't trigger a notification anymore.
			// Because completed checkins where either checked out by the user manually,
			// or they where checked out by the "automatic checkout" of checkoutOverdueCheckins().
			self?.cancelAllCheckoutNotifications {
				checkins.forEach {
					if $0.checkinCompleted {
						self?.createJournalEntries(for: $0)
						// If the User chooses to add the event to contact diary we need to change the "createJournalEntry" flag to false AFTER the first time of calling createJournalEntries()
						// Otherwise if the user decides to delete the event from the contact journal, the event will be Re-added to the contact journal when we call the current function again since the flag is still true
						// We also need to guard and only update the models that have the "createJournalEntry" flag set to true
						// Otherwise we will have an infinite loop as every time we modify the checking we will can the sing of the checkinsPublisher
						if $0.createJournalEntry {
							self?.eventStore.updateCheckin($0.updatedCheckin(createJournalEntry: false))
						}
					} else {
						self?.triggerNotificationForCheckout(of: $0)
					}
				}
			}
		}.store(in: &subscriptions)
	}

	private func triggerNotificationForCheckout(of checkin: Checkin) {
		Log.info("[EventCheckoutService] Trigger notification for checkin with id: \(checkin.id) and endDate: \(checkin.checkinEndDate)", log: .checkin)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.Checkout.notificationTitle
		content.body = AppStrings.Checkout.notificationBody
		content.sound = .default

		let checkinEndDateComponents = Calendar.current.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: checkin.checkinEndDate
		)

		let trigger = UNCalendarNotificationTrigger(dateMatching: checkinEndDateComponents, repeats: false)

		let request = UNNotificationRequest(
			identifier: checkin.notificationIdentifier,
			content: content,
			trigger: trigger
		)

		userNotificationCenter.add(request) { error in
			if error != nil {
				Log.error("Checkout notification could not be scheduled.")
			}
		}
	}

	private func cancelAllCheckoutNotifications(completion: @escaping () -> Void) {
		Log.info("[EventCheckoutService] Cancel all notifications.", log: .checkin)

		userNotificationCenter.getPendingNotificationRequests { [weak self] requests in
			let notificationIds = requests.map {
				$0.identifier
			}.filter {
				$0.contains(LocalNotificationIdentifier.checkout.rawValue)
			}

			self?.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIds)

			completion()
		}
	}

	private func createJournalEntries(for checkin: Checkin) {
		Log.info("[EventCheckoutService] Create contact journal entries for checkin with id: \(checkin.id).", log: .checkin)

		guard checkin.createJournalEntry else {
			return
		}

		// Create the location entry if it does not exist.

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

		var locationId: Int?

		if !checkinLocationExists {
			locationId = createLocation(for: checkin)
		}

		// Create location visits if the checkin location visits does not exist.

		let locationVisits: [LocationVisit] = contactDiaryStore.diaryDaysPublisher.value.reduce(into: [LocationVisit]()) {
			let visits = $1.entries.reduce(into: [LocationVisit]()) {
				if case let .location(location) = $1 {
					if let visit = location.visit {
						$0.append(visit)
					}
				}
			}
			$0.append(contentsOf: visits)
		}

		let checkinLocationVisitExists = locationVisits.contains {
			$0.checkinId == checkin.id
		}

		if !checkinLocationVisitExists {
			if locationId == nil {
				locationId = locations.first(where: {
					$0.traceLocationId == checkin.traceLocationId
				})?.id
			}

			guard let _locationId = locationId else {
				return
			}

			createLocationVisits(for: checkin, locationId: _locationId)
		}
	}

	private func createLocation(for checkin: Checkin) -> Int? {
		Log.info("[EventCheckoutService] Create contact journal location for checkin with id: \(checkin.id).", log: .checkin)

		var locationNameElements = [String]()

		if !checkin.traceLocationDescription.isEmpty {
			locationNameElements.append(checkin.traceLocationDescription)
		}

		if !checkin.traceLocationAddress.isEmpty {
			locationNameElements.append(checkin.traceLocationAddress)
		}

		let addLocationResult = contactDiaryStore.addLocation(
			name: locationNameElements.joined(separator: ", "),
			phoneNumber: "",
			emailAddress: "",
			traceLocationId: checkin.traceLocationId
		)

		if case let .success(locationId) = addLocationResult {
			return locationId
		} else {
			return nil
		}
	}

	private func createLocationVisits(for checkin: Checkin, locationId: Int) {
		Log.info("[EventCheckoutService] Create contact journal location visits for checkin with id: \(checkin.id).", log: .checkin)

		let splittedCheckins = CheckinSplittingService().split(checkin)
		splittedCheckins.forEach { checkin in

			// Check if there is already an visit of the same location on the same day.

			// Find the day entry for the day of the checkin.
			let diaryDayForTheSameDay = contactDiaryStore.diaryDaysPublisher.value.first(where: {
				$0.dateString == justLocalDateFormatter.string(
					from: checkin.checkinStartDate
				   )
			})

			var locationVisitForSameDayExists = false

			if let diaryDayForTheSameDay = diaryDayForTheSameDay {

				// Check if there is already an LocationVisit entry for the Checkins TraceLocation on the same day.
				// If yes, this means, that there was already another Checkin with the same TraceLocation at the same day.
				// In this case, we don't add another LocationVisit entry. Because more then 1 LocationVisit for the same DiaryLoacation at the same day is not supported by the Contact Journal UI.
				let traceLocationIds = diaryDayForTheSameDay.entries.reduce(into: [Data]()) {
					if case let .location(location) = $1 {
						if location.visit != nil, let traceLocationId = location.traceLocationId {
							$0.append(traceLocationId)
						}
					}
				}

				locationVisitForSameDayExists = traceLocationIds.contains(where: {
					$0 == checkin.traceLocationId
				})
			}

			// If there is already an entry for the same day of the checkin, dont create an location visit.
			if !locationVisitForSameDayExists {
				contactDiaryStore.addLocationVisit(
					locationId: locationId,
					date: justLocalDateFormatter.string(
						from: checkin.checkinStartDate
					),
					durationInMinutes: checkin.roundedDurationIn15mSteps,
					circumstances: "",
					checkinId: checkin.id
				)
			}
		}
	}

	private func registerToDidBecomeActiveNotification() {
		Log.info("[EventCheckoutService] Register to 'DidBecomeActive' notification.", log: .checkin)

		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		Log.info("[EventCheckoutService] 'DidBecomeActive' notification triggered.", log: .checkin)

		checkoutOverdueCheckins()
	}

	private var justLocalDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter.justLocalDateFormatter
		return dateFormatter
	}()
}

private extension Checkin {

	var notificationIdentifier: String {
		LocalNotificationIdentifier.checkout.rawValue + "\(id)"
	}
}
