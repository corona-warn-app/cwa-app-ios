//
// 🦠 Corona-Warn-App
//

import UIKit
@testable import ENA

class MockBackgroundRefreshStatusProvider: BackgroundRefreshStatusProviding {

	// MARK: - Init

	init(backgroundRefreshStatus: UIBackgroundRefreshStatus) {
		self.backgroundRefreshStatus = backgroundRefreshStatus
	}

	// MARK: - Internal

	var backgroundRefreshStatus: UIBackgroundRefreshStatus

}
