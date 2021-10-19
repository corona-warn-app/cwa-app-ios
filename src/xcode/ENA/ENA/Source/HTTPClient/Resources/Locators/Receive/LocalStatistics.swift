//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func localStatistics(
		groupID: StatisticsGroupIdentifier
	) -> Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "local_stats_\(groupID)"],
			method: .get
		)
	}

}
