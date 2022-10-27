////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinCellModel: EventCellModel {

	// MARK: - Init

	init(
		checkin: Checkin,
		eventCheckoutService: EventCheckoutService,
		onUpdate: @escaping () -> Void
	) {
		self.checkin = checkin
		self.eventCheckoutService = eventCheckoutService
		self.onUpdate = onUpdate

		updateForActiveState()
		scheduleUpdateTimer()
	}

	// MARK: - Internal

	var checkin: Checkin

	var isInactiveIconHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isActiveContainerViewHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isButtonHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var titleAccessibilityLabelPublisher = CurrentValueSubject<String?, Never>(nil)
	var durationPublisher = CurrentValueSubject<String?, Never>(nil)
	var durationAccessibilityPublisher = CurrentValueSubject<String?, Never>(nil)
	var timePublisher = CurrentValueSubject<String?, Never>(nil)
	var timeAccessibilityPublisher = CurrentValueSubject<String?, Never>(nil)

	var isActiveIconHidden: Bool = true
	var isDurationStackViewHidden: Bool = false

	var title: NSAttributedString {
		checkin.traceLocationDescription.withHyphenationStyle()
	}

	var address: String {
		checkin.traceLocationAddress
	}

	var buttonTitle: String = AppStrings.Checkins.Overview.checkoutButtonTitle

	func update(with checkin: Checkin) {
		guard checkin != self.checkin else {
			return
		}

		self.checkin = checkin
		updateForActiveState()
		onUpdate()
	}

	@objc
	func invalidateTimer() {
		updateTimer?.invalidate()
	}

	// MARK: - Private

	private let eventCheckoutService: EventCheckoutService
	private let onUpdate: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	private var updateTimer: Timer?

	private func updateForActiveState() {
		isInactiveIconHiddenPublisher.value = !checkin.checkinCompleted
		isActiveContainerViewHiddenPublisher.value = checkin.checkinCompleted
		isButtonHiddenPublisher.value = checkin.checkinCompleted

		if checkin.checkinCompleted {
			let dateFormatter = DateIntervalFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short

			timePublisher.value = dateFormatter.string(from: checkin.checkinStartDate, to: checkin.checkinEndDate)
			titleAccessibilityLabelPublisher.value = String(format: AppStrings.Checkins.Overview.itemPrefixCheckedOut, checkin.traceLocationDescription)
			
			let timeAccessibilityDateFormatter = DateIntervalFormatter()
			timeAccessibilityDateFormatter.dateStyle = .long
			timeAccessibilityDateFormatter.timeStyle = .medium
			let formattedAccessibilityCheckinTime = timeAccessibilityDateFormatter.string(from: checkin.checkinStartDate, to: checkin.checkinEndDate)
			timeAccessibilityPublisher.value = String(format: AppStrings.Checkins.Overview.checkinDateTemplate, formattedAccessibilityCheckinTime)
		} else {
			let formattedCheckinTime = DateFormatter.localizedString(from: checkin.checkinStartDate, dateStyle: .short, timeStyle: .short)
			
			var formattedAccessibilityCheckinTime = DateFormatter.localizedString(from: checkin.checkinStartDate, dateStyle: .long, timeStyle: .medium)
			formattedAccessibilityCheckinTime = String(format: AppStrings.Checkins.Overview.checkinDateTemplate, formattedAccessibilityCheckinTime)

			let dateComponentsFormatter = DateComponentsFormatter()
			dateComponentsFormatter.allowedUnits = [.hour, .minute]
			dateComponentsFormatter.unitsStyle = .short

			if let formattedAutomaticCheckoutDuration = dateComponentsFormatter.string(from: checkin.checkinEndDate.timeIntervalSince(checkin.checkinStartDate)) {
				timePublisher.value = String(format: AppStrings.Checkins.Overview.checkinTimeTemplate, formattedCheckinTime, formattedAutomaticCheckoutDuration)
				timeAccessibilityPublisher.value = String(format: AppStrings.Checkins.Overview.checkinTimeTemplate, formattedAccessibilityCheckinTime, formattedAutomaticCheckoutDuration)
			} else {
				timePublisher.value = formattedCheckinTime
				timeAccessibilityPublisher.value = formattedAccessibilityCheckinTime
			}
			titleAccessibilityLabelPublisher.value = String(format: AppStrings.Checkins.Overview.itemPrefixCheckIn, checkin.traceLocationDescription)
		}

		let duration = Date().timeIntervalSince(checkin.checkinStartDate)

		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad

		durationPublisher.value = dateComponentsFormatter.string(from: duration)

		let components = Calendar.utcCalendar.dateComponents([.hour, .minute], from: Date(timeIntervalSinceReferenceDate: duration))
		durationAccessibilityPublisher.value = DateComponentsFormatter.localizedString(from: components, unitsStyle: .spellOut)
	}

	private func scheduleUpdateTimer() {
		updateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard !checkin.checkinCompleted else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		let now = Date()
		let currentSeconds = Calendar.current.component(.second, from: now)
		let checkinSeconds = Calendar.current.component(.second, from: checkin.checkinStartDate)
		let timeToNextCheckinSeconds = (60 - (currentSeconds - checkinSeconds)) % 60
		let firstFireDate = now.addingTimeInterval(TimeInterval(timeToNextCheckinSeconds))

		updateTimer = Timer(fireAt: firstFireDate, interval: 60, target: self, selector: #selector(updateFromTimer), userInfo: nil, repeats: true)
		guard let updateTimer = updateTimer else { return }
		RunLoop.current.add(updateTimer, forMode: .common)
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateFromTimer()
		scheduleUpdateTimer()
	}

	@objc
	private func updateFromTimer() {
		eventCheckoutService.checkoutOverdueCheckins()
		updateForActiveState()
		onUpdate()
	}
    
}
