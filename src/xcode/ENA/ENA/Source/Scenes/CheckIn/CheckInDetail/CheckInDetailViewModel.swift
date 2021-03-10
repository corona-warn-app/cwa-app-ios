////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInDetailViewModel {

	// MARK: - Init
	init(
		_ checkin: Checkin
	) {
		self.checkin = checkin
	}

	// MARK: - Private

	private let checkin: Checkin

}
