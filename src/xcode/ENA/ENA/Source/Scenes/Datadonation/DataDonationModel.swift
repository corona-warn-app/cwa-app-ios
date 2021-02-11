////
// 🦠 Corona-Warn-App
//

import Foundation

struct DataDonationModel {

	// MARK: - Init

	init(
		store: Store,
		jsonFileURL: URL
	) {
		self.store = store
		self.isConsentGiven = store.isPrivacyPreservingAnalyticsConsentGiven

		let userMetadata = store.userMetadata
		self.federalStateName = userMetadata?.federalState?.rawValue
		self.age = userMetadata?.ageGroup?.text

		do {
			let jsonData = try Data(contentsOf: jsonFileURL)
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

	// store alle data if the user consent is given
	// otherwise set all values to nil and store that consent isn't give only
	mutating func save() {
		store.isPrivacyPreservingAnalyticsConsentGiven = isConsentGiven
		guard isConsentGiven else {
			store.userMetadata = UserMetadata(federalState: nil, administrativeUnit: nil, ageGroup: nil)
			region = nil
			federalStateName = nil
			age = nil
			return
		}
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
