////
// 🦠 Corona-Warn-App
//

import Foundation

/** Fake struct for the moment */
struct Event {
	let uuid: String
	let title: String
	let adress: String
	let startTimestamp: Date
	let duration: TimeInterval
}

final class CheckInDetailViewModel {

	// MARK: - Init
	init(
		_ event: Event
	) {
		self.event = event
	}

	// MARK: - Private

	private let event: Event

}
