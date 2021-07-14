////
// 🦠 Corona-Warn-App
//

import Foundation

struct LocalStatisticsModel {

	// MARK: - Init

	init() {
		guard let jsonFileURL = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}
		do {
			let jsonData = try Data(contentsOf: jsonFileURL)
			self.allDistricts = try JSONDecoder().decode([DistrictElement].self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .localStatistics)
			self.allDistricts = []
		}
	}

	// MARK: - Internal

	var allFederalStateNames: [String] {
		FederalStateName.allCases.map { $0.rawValue }
	}

	func allRegions(by federalStateName: String) -> [String] {
		allDistricts.filter { district -> Bool in
			district.federalStateName.rawValue == federalStateName
		}
		.map { $0.districtName }
	}
	func regionId(by region: String) -> DistrictElement? {
		allDistricts.first(where: { district -> Bool in
			district.districtName == region
		})
	}

	// MARK: - Private

	private let allDistricts: [DistrictElement]
}
