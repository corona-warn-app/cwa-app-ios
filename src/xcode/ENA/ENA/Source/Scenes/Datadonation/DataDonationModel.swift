////
// 🦠 Corona-Warn-App
//

import Foundation

struct DataDonationModel {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
		self.isConsentGiven = store.isPrivacyPreservingAnalyticsConsentGiven

		let userMetadata = store.userMetadata
		self.federalStateName = userMetadata?.federalState?.rawValue
		self.age = userMetadata?.ageGroup?.text

		guard let jsonFileUrl = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			Log.debug("Failed to find url to json file", log: .ppac)
			self.allDistricts = []
			self.region = ""
			return
		}

		do {
			let jsonData = try Data(contentsOf: jsonFileUrl)
			self.allDistricts = try JSONDecoder().decode([DistrictElement].self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			self.allDistricts = []
		}

		self.region = allDistricts.first { districtElement -> Bool in
			districtElement.districtID == userMetadata?.administrativeUnit
		}?.districtName
	}

	// MARK: - Public

	// MARK: - Internal

	var isConsentGiven: Bool
	var federalStateName: String?
	var region: String?
	var age: String?

	var allFederalStateNames: [String] {
		FederalStateName.allCases.map { $0.rawValue }
	}

	func allRegions(by federalStateName: String) -> [String] {
		allDistricts.filter { district -> Bool in
			district.federalStateName.rawValue == federalStateName
		}
		.map { $0.districtName }
	}

	func save() {
		store.isPrivacyPreservingAnalyticsConsentGiven = isConsentGiven

		let ageGroup = AgeGroup(from: self.age)
		let district = allDistricts.first(where: { districtElement -> Bool in
				districtElement.districtName == region
			  }
		)

		var federalStateNameEnum: FederalStateName?
		if let federaStateName = federalStateName {
			federalStateNameEnum = FederalStateName(rawValue: federaStateName)
		}

		let userMetaData = UserMetadata(
			federalState: federalStateNameEnum,
			administrativeUnit: district?.districtID,
			ageGroup: ageGroup)

		store.userMetadata = userMetaData
	}

	// MARK: - Private

	private let store: Store
	private let allDistricts: [DistrictElement]

}
