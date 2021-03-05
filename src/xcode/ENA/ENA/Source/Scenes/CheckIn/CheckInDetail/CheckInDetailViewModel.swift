////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInDetailViewModel {

	// MARK: - Init
	init(
		_ event: String
	) {
		self.event = event
	}

	// MARK: - Private

	private let event: String

}
