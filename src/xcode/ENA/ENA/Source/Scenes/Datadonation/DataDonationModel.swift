////
// 🦠 Corona-Warn-App
//

import Foundation

struct DataDonationModel {

	// MARK: - Init

	init(
		store: Store,
		federalStateName: String? = nil,
		region: String? = nil,
		age: String? = nil
	) {
		self.store = store

		self.isConsentGiven = store.privacyPreservingAnalyticsConsentAccept
		self.federalStateName = federalStateName
		self.region = region
		self.age = age

		guard let jsonFileUrl = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			Log.debug("Failed to find url to json file", log: .ppac)
			self.allDistricts = []
			return
		}

		do {
			let jsonData = try Data(contentsOf: jsonFileUrl)
			self.allDistricts = try JSONDecoder().decode([DistrictElement].self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			self.allDistricts = []
		}

	}

	// MARK: - Public

	// MARK: - Internal

	var isConsentGiven: Bool
	var federalStateName: String?
	var region: String?
	var age: String?

	func allRegions(by federalStateName: String) -> [String] {
		allDistricts.filter { district -> Bool in
			district.federalStateName.rawValue == federalStateName
		}
		.map { $0.districtName }
	}

	var allFederalStateNames: [String] {
		FederalStateName.allCases.map { $0.rawValue }
	}


	// MARK: - Private

	private let store: Store
	private let allDistricts: [DistrictElement]
}
