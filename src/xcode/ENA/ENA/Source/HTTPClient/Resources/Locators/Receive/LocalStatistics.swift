//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	ProtoBuf SAP_Internal_Stats_LocalStatistics
	// type:	caching
	// comment:


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
