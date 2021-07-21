////
// 🦠 Corona-Warn-App
//

import Foundation

struct RegionStatisticsData {
	var regionName: String
	var id: Int = 0
	var updatedAt: Int64 = 0
	var sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData
}
