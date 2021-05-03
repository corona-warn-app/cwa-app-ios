//
// 🦠 Corona-Warn-App
//

import Foundation

struct VaccinationValueDataSets: Codable, Equatable {
	
	// MARK: - Init
	
	init(with response: VaccinationValueSetsResponse) {
		self.lastValueDataSetsETag = response.eTag
		self.lastValueDataSetsFetchDate = response.timestamp
		self.valueDataSets = response.valueSets
	}

	init(
		lastValueDataSetsETag: String,
		lastValueDataSetsDate: Date,
		valueDataSets: SAP_Internal_Dgc_ValueSets
	) {
		self.lastValueDataSetsETag = lastValueDataSetsETag
		self.lastValueDataSetsFetchDate = lastValueDataSetsDate
		self.valueDataSets = valueDataSets
	}
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case lastValueDataSetsETag
		case lastValueDataSetsFetchDate
		case valueDataSets
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		lastValueDataSetsETag = try container.decode(String.self, forKey: .lastValueDataSetsETag)
		lastValueDataSetsFetchDate = try container.decode(Date.self, forKey: .lastValueDataSetsFetchDate)

		let valueDataSetsData = try container.decode(Data.self, forKey: .valueDataSets)
		valueDataSets = try SAP_Internal_Dgc_ValueSets(serializedData: valueDataSetsData)
	}
	
	func encode(to encoder: Encoder) throws {}
	
	// MARK: - Internal
	
	var lastValueDataSetsETag: String?
	var lastValueDataSetsFetchDate: Date
	var valueDataSets: SAP_Internal_Dgc_ValueSets
	
	mutating func refreshLastVaccinationValueDataSetsFetchDate() {
		lastValueDataSetsFetchDate = Date()
	}
}
