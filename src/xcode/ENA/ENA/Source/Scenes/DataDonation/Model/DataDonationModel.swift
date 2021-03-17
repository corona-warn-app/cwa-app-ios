//
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

		let userMetadata = store.userData
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
	// otherwise store that consent isn't give only
	mutating func save() {
		store.isPrivacyPreservingAnalyticsConsentGiven = isConsentGiven

		// If user has not given or revoked his consent, delete all analytics data and the userData.
		guard isConsentGiven else {
			region = nil
			federalStateName = nil
			age = nil
			Analytics.deleteAnalyticsData()
			return
		}
		let ageGroup = AgeGroup(from: self.age)
		let district = allDistricts.first(where: { districtElement -> Bool in
			districtElement.districtName == region
		}
		)

		var federalStateNameEnum: FederalStateName?
		if let federalStateName = federalStateName {
			federalStateNameEnum = FederalStateName(rawValue: federalStateName)
		}

		let userdata = UserMetadata(
			federalState: federalStateNameEnum,
			administrativeUnit: district?.districtID,
			ageGroup: ageGroup)

		store.userData = userdata
	}

	// MARK: - Private

	private let store: Store
	private let allDistricts: [DistrictElement]

}
