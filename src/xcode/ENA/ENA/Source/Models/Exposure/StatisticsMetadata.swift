////
// 🦠 Corona-Warn-App
//

import Foundation

struct StatisticsMetadata: Codable {

	var lastStatisticsETag: String?
	var lastStatisticsFetch: Date
	var statistics: SAP_Internal_Stats_Statistics

	enum CodingKeys: String, CodingKey {
		case lastStatisticsETag
		case lastStatisticsFetch
		case statistics
	}

	init(with response: StatisticsFetchingResponse) {
		lastStatisticsETag = response.eTag
		lastStatisticsFetch = response.timestamp
		statistics = response.stats
	}

	// Used for unit tests
	init(stats: SAP_Internal_Stats_Statistics, eTag: String?, timestamp: Date = Date()) {
		lastStatisticsETag = eTag
		lastStatisticsFetch = timestamp
		statistics = stats
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		lastStatisticsETag = try container.decode(String.self, forKey: .lastStatisticsETag)
		lastStatisticsFetch = try container.decode(Date.self, forKey: .lastStatisticsFetch)

		let data = try container.decode(Data.self, forKey: .statistics)
		statistics = try SAP_Internal_Stats_Statistics(serializedData: data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(lastStatisticsETag, forKey: .lastStatisticsETag)
		try container.encode(lastStatisticsFetch, forKey: .lastStatisticsFetch)

		let data = try statistics.serializedData()
		try container.encode(data, forKey: .statistics)
	}

	mutating func refeshLastFetchDate() {
		lastStatisticsFetch = Date()
	}
}
