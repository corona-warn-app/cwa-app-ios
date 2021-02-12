//
// 🦠 Corona-Warn-App
//

import Foundation

struct UserMetadata: Codable {
	var federalState: FederalStateName?
	// reference districtID
	var administrativeUnit: Int?
	var ageGroup: AgeGroup?

	enum CodingKeys: String, CodingKey {
		case federalState
		case administrativeUnit
		case ageGroup
	}

	init(
		federalState: FederalStateName?,
		administrativeUnit: Int?,
		ageGroup: AgeGroup?
	) {
		self.federalState = federalState
		self.administrativeUnit = administrativeUnit
		self.ageGroup = ageGroup
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		federalState = try container.decodeIfPresent(FederalStateName.self, forKey: .federalState)
		administrativeUnit = try container.decodeIfPresent(Int.self, forKey: .administrativeUnit)
		ageGroup = try container.decodeIfPresent(AgeGroup.self, forKey: .ageGroup)
	}
}
