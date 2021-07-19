//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsRegion: Codable, Equatable {
	let federalState: LocalStatisticsFederalState
	let name: String
	let id: String
	let regionType: RegionType
}

enum RegionType: String, CaseIterable, Codable {
	case federalState
	case administrativeUnit
}


struct SevenDayData {
	var regionName: String
	var id: Int = 0
	var updatedAt: Int64 = 0
	var sevenDayIncidence: SAP_Internal_Stats_SevenDayIncidenceData
}
