//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsDistrict: Codable, Equatable {
	
	// MARK: - Init

	init(
		federalState: LocalStatisticsFederalState,
		districtName: String,
		districtId: String
	) {
		self.federalState = federalState
		self.districtName = districtName
		self.districtId = districtId
	}

	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case federalState
		case districtName
		case districtId
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		federalState = try container.decode(LocalStatisticsFederalState.self, forKey: .federalState)
		districtName = try container.decode(String.self, forKey: .districtName)
		districtId = try container.decode(String.self, forKey: .districtId)
	}
		
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(federalState, forKey: .federalState)
		try container.encode(districtName, forKey: .districtName)
		try container.encode(districtId, forKey: .districtId)
	}
	
	// MARK: - Internal
	
	var federalState: LocalStatisticsFederalState
	var districtName: String
	var districtId: String

}

// TODO: Should be moved after overall refactoring

struct SelectedLocalStatisticsTuple {
	
	// MARK: - Init

	init(
		localStatisticsData: SAP_Internal_Stats_LocalStatistics,
		localStatisticsDistrict: LocalStatisticsDistrict
	) {
		self.localStatisticsData = localStatisticsData
		self.localStatisticsDistrict = localStatisticsDistrict
	}
	
	// MARK: - Internal

	var localStatisticsData: SAP_Internal_Stats_LocalStatistics
	var localStatisticsDistrict: LocalStatisticsDistrict
}
