//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsDistrict: Codable, Equatable {
	let federalState: LocalStatisticsFederalState
	let districtName: String
	let districtId: String
}
