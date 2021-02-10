//
// 🦠 Corona-Warn-App
//

@testable import ENA

struct MockDeadmanNotificationManager: DeadmanNotificationManageable {

	// MARK: - Protocol DeadmanNotificationManageable

	func scheduleDeadmanNotificationIfNeeded() {
		scheduleDeadmanNotificationIfNeededCalled?()
	}

	func resetDeadmanNotification() {
		resetDeadmanNotificationCalled?()
	}

	// MARK: - Internal

	var scheduleDeadmanNotificationIfNeededCalled: (() -> Void)?
	var resetDeadmanNotificationCalled: (() -> Void)?

}
