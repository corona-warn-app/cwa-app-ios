//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class MockLowPowerModeStatusProvider: LowPowerModeStatusProviding {

	// MARK: - Init

	init(isLowPowerModeEnabled: Bool) {
		self.isLowPowerModeEnabled = isLowPowerModeEnabled
	}

	// MARK: - Internal

	var isLowPowerModeEnabled: Bool

}
