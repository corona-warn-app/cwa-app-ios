//
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsMetadata: Codable, Equatable {
	
	// MARK: - Init
	
	init(with response: LocalStatisticsResponse) {
		self.lastLocalStatisticsETag = response.eTag
		self.lastLocalStatisticsFetchDate = response.timestamp
		self.localStatistics = response.localStatistics
	}

	init(
		lastLocalStatisticsETag: String,
		lastLocalStatisticsFetchDate: Date,
		localStatistics: SAP_Internal_Stats_LocalStatistics
	) {
		self.lastLocalStatisticsETag = lastLocalStatisticsETag
		self.lastLocalStatisticsFetchDate = lastLocalStatisticsFetchDate
		self.localStatistics = localStatistics
	}
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case lastLocalStatisticsETag
		case lastLocalStatisticsFetchDate
		case localStatistics
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		lastLocalStatisticsETag = try container.decode(String.self, forKey: .lastLocalStatisticsETag)
		lastLocalStatisticsFetchDate = try container.decode(Date.self, forKey: .lastLocalStatisticsFetchDate)

		let localStatisticsData = try container.decode(Data.self, forKey: .localStatistics)
		localStatistics = try SAP_Internal_Stats_LocalStatistics(serializedData: localStatisticsData)
	}
		
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(lastLocalStatisticsETag, forKey: .lastLocalStatisticsETag)
		try container.encode(lastLocalStatisticsFetchDate, forKey: .lastLocalStatisticsFetchDate)

		let localStatistics = try localStatistics.serializedData()
		try container.encode(localStatistics, forKey: .localStatistics)
	}
	
	// MARK: - Internal
	
	var lastLocalStatisticsETag: String?
	var lastLocalStatisticsFetchDate: Date
	var localStatistics: SAP_Internal_Stats_LocalStatistics
	
	mutating func refreshLastLocalStatisticsFetchDate() {
		lastLocalStatisticsFetchDate = Date()
	}
}
