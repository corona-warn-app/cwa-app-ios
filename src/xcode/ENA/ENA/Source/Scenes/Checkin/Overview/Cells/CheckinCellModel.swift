////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinCellModel: EventCellModel {

	// MARK: - Init

	init(
		checkin: Checkin,
		eventProvider: EventProviding,
		onUpdate: @escaping () -> Void
	) {
		self.checkin = checkin
		self.onUpdate = onUpdate

		updateForActiveState()
		scheduleUpdateTimer()
	}

	// MARK: - Internal

	var checkin: Checkin

	var isInactiveIconHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isActiveContainerViewHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var isButtonHiddenPublisher = CurrentValueSubject<Bool, Never>(true)
	var durationPublisher = CurrentValueSubject<String?, Never>(nil)
	var timePublisher = CurrentValueSubject<String?, Never>(nil)

	var isActiveIconHidden: Bool = true
	var isDurationStackViewHidden: Bool = false

	var date: String? {
		DateFormatter.localizedString(from: checkin.checkinStartDate, dateStyle: .short, timeStyle: .none)
	}

	var title: String {
		checkin.traceLocationDescription
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

	// MARK: - Private

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
		} else {
			let formattedCheckinTime = DateFormatter.localizedString(from: checkin.checkinStartDate, dateStyle: .none, timeStyle: .short)

			let dateComponentsFormatter = DateComponentsFormatter()
			dateComponentsFormatter.allowedUnits = [.hour, .minute]
			dateComponentsFormatter.unitsStyle = .short

			if let formattedAutomaticCheckoutDuration = dateComponentsFormatter.string(from: checkin.checkinEndDate.timeIntervalSince(checkin.checkinStartDate)) {
				timePublisher.value = String(format: AppStrings.Checkins.Overview.checkinTimeTemplate, formattedCheckinTime, formattedAutomaticCheckoutDuration)
			} else {
				timePublisher.value = formattedCheckinTime
			}
		}

		let duration = Date().timeIntervalSince(checkin.checkinStartDate)

		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad

		durationPublisher.value = dateComponentsFormatter.string(from: duration)
	}

	private func scheduleUpdateTimer() {
		updateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard !checkin.checkinCompleted else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateUpdatedTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
	private func invalidateUpdatedTimer() {
		updateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		scheduleUpdateTimer()
	}

	@objc
	private func updateFromTimer() {
		updateForActiveState()
		onUpdate()
	}
    
}
