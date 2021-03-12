////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol EventCellModel {

	var isInactiveIconHiddenPublisher: OpenCombine.Published<Bool>.Publisher { get }
	var isActiveContainerViewHiddenPublisher: OpenCombine.Published<Bool>.Publisher { get }
	var isButtonHiddenPublisher: OpenCombine.Published<Bool>.Publisher { get }
	var durationPublisher: OpenCombine.Published<String?>.Publisher { get }
	var timePublisher: OpenCombine.Published<String?>.Publisher { get }

	var isActiveIconHidden: Bool { get }
	var isDurationStackViewHidden: Bool { get }

	var date: String { get }

	var title: String { get }
	var address: String { get }

	var buttonTitle: String { get }

}

class TraceLocationCellModel: EventCellModel {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		eventProvider: EventProviding,
		onUpdate: @escaping () -> Void
	) {
		self.traceLocation = traceLocation
		self.onUpdate = onUpdate

		eventProvider.checkinsPublisher
			.sink { [weak self] checkins in
				self?.isButtonHidden = checkins.contains { $0.traceLocationGUID == traceLocation.guid }
				onUpdate()
			}
			.store(in: &subscriptions)

		updateForActiveState()
		scheduleUpdateTimer()
	}

	// MARK: - Internal

	var isInactiveIconHiddenPublisher: OpenCombine.Published<Bool>.Publisher { $isInactiveIconHidden }
	var isActiveContainerViewHiddenPublisher: OpenCombine.Published<Bool>.Publisher { $isActiveContainerViewHidden }
	var isButtonHiddenPublisher: OpenCombine.Published<Bool>.Publisher { $isButtonHidden }
	var durationPublisher: OpenCombine.Published<String?>.Publisher { $duration }
	var timePublisher: OpenCombine.Published<String?>.Publisher { $time }

	var isActiveIconHidden: Bool = false
	var isDurationStackViewHidden: Bool = true

	var date: String {
		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		return dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)
	}

	var title: String {
		traceLocation.description
	}

	var address: String {
		traceLocation.address
	}

	var buttonTitle: String = AppStrings.TraceLocations.Overview.selfCheckinButtonTitle

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let onUpdate: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	@OpenCombine.Published private var isInactiveIconHidden: Bool = true
	@OpenCombine.Published private var isActiveContainerViewHidden: Bool = true
	@OpenCombine.Published private var isButtonHidden: Bool = true
	@OpenCombine.Published private var duration: String?
	@OpenCombine.Published private var time: String?

	private var updateTimer: Timer?

	@objc
	private func updateForActiveState() {
		isInactiveIconHidden = traceLocation.isActive
		isActiveContainerViewHidden = !traceLocation.isActive

		let dateFormatter = DateIntervalFormatter()
		dateFormatter.dateStyle = traceLocation.isActive ? .none : .short
		dateFormatter.timeStyle = .short

		time = dateFormatter.string(from: traceLocation.startDate, to: traceLocation.endDate)

		onUpdate()
	}

	private func scheduleUpdateTimer() {
		updateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		// Schedule new countdown.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateUpdatedTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		updateTimer = Timer(fireAt: traceLocation.endDate, interval: 0, target: self, selector: #selector(updateForActiveState), userInfo: nil, repeats: false)
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
    
}

private extension TraceLocation {

	var isActive: Bool {
		Date() < endDate
	}

}
