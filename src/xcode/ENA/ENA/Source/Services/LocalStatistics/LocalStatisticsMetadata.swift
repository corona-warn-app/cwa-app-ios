//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsMetadata: Codable, Equatable {
	
	// MARK: - Init
	
	init(with response: LocalStatisticsResponse) {
		self.groupID = response.groupID
		self.lastLocalStatisticsETag = response.eTag
		self.lastLocalStatisticsFetchDate = response.timestamp
		self.localStatistics = response.localStatistics
	}

	init(
		groupID: StatisticsGroupIdentifier,
		lastLocalStatisticsETag: String,
		lastLocalStatisticsFetchDate: Date,
		localStatistics: SAP_Internal_Stats_LocalStatistics
	) {
		self.groupID = groupID
		self.lastLocalStatisticsETag = lastLocalStatisticsETag
		self.lastLocalStatisticsFetchDate = lastLocalStatisticsFetchDate
		self.localStatistics = localStatistics
	}
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case groupID
		case lastLocalStatisticsETag
		case lastLocalStatisticsFetchDate
		case localStatistics
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		groupID = try container.decode(String.self, forKey: .groupID)
		lastLocalStatisticsETag = try container.decode(String.self, forKey: .lastLocalStatisticsETag)
		lastLocalStatisticsFetchDate = try container.decode(Date.self, forKey: .lastLocalStatisticsFetchDate)

		let localStatisticsData = try container.decode(Data.self, forKey: .localStatistics)
		localStatistics = try SAP_Internal_Stats_LocalStatistics(serializedData: localStatisticsData)
	}
		
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(groupID, forKey: .groupID)
		try container.encode(lastLocalStatisticsETag, forKey: .lastLocalStatisticsETag)
		try container.encode(lastLocalStatisticsFetchDate, forKey: .lastLocalStatisticsFetchDate)

		let localStatistics = try self.localStatistics.serializedData()
		try container.encode(localStatistics, forKey: .localStatistics)
	}
	
	// MARK: - Internal
	
	var groupID: StatisticsGroupIdentifier
	var lastLocalStatisticsETag: String?
	var lastLocalStatisticsFetchDate: Date
	var localStatistics: SAP_Internal_Stats_LocalStatistics
	
	mutating func refreshLastLocalStatisticsFetchDate() {
		lastLocalStatisticsFetchDate = Date()
	}
}
