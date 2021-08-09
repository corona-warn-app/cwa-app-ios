//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsRegion: Codable, Equatable {
	let federalState: LocalStatisticsFederalState
	let name: String
	let id: String
	let regionType: RegionType
	
	// returns localized name for a region
	var localizedName: String {
		switch regionType {
		case .federalState:
			return federalState.localizedName
		case .administrativeUnit:
			return name
		}
	}
}
