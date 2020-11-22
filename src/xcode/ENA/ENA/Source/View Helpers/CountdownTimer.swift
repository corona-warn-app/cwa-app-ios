//
// 🦠 Corona-Warn-App
//

import Foundation

// MARK: - CountdownTimer.

/// Helper class that wraps a Timer and provides convenience methods.
class CountdownTimer {

	// MARK: - Attributes.

	weak var delegate: CountdownTimerDelegate?
	private var timer: Timer?
	private(set) var end: Date

	// MARK: - Public Methods.

	init(countdownTo date: Date) {
		self.end = date
	}

	deinit {
		invalidate()
	}

	func invalidate() {
		timer?.invalidate()
		timer = nil
	}

	func start() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(
			withTimeInterval: 1.0,
			repeats: true,
			block: action
		)
		guard let timer = timer else { return }
		RunLoop.main.add(timer, forMode: .common)
		timer.fire()
	}

	// MARK: - Private Helpers.

	private func action(_ timer: Timer? = nil) {
		guard end >= Date() else {
			timer?.invalidate()
			delegate?.countdownTimer(self, didEnd: true)
			return
		}

		update()
	}

	private func update() {
		let components = Calendar.current.dateComponents(
			[.hour, .minute, .second],
			from: Date(),
			to: end
		)
		delegate?.countdownTimer(self, didUpdate: CountdownTimer.format(components))
	}

	static func format(_ components: DateComponents) -> String {
		let hours = String(format: "%02d", components.hour ?? 0)
		let minutes = String(format: "%02d", components.minute ?? 0)
		let seconds = String(format: "%02d", components.second ?? 0)
		return "\(hours):\(minutes):\(seconds)"
	}
}

// MARK: - CountdownTimerDelegate.

/// Provides callback methods that are called once per second (`update(_)`) until the countdown has finished.
protocol CountdownTimerDelegate: class {
	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String)
	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool)
}
