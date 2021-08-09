//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsRegion: Codable, Equatable {
	let federalState: LocalStatisticsFederalState
	let name: String
	let id: String
	let regionType: RegionType
	
	// returns localized name based on region type
	var localizedName: String {
		switch regionType {
		case .federalState:
			// return localized name for federal state
			return federalState.localizedName
		case .administrativeUnit:
			// just return the name in case of administrative unit
			return name
		}
	}
}
