////
// 🦠 Corona-Warn-App
//

import Foundation

struct DataDonationModel {

	// MARK: - Init

	init(
		isConsentGiven: Bool = false,
		federalStateName: String? = nil,
		region: String? = nil,
		age: String? = nil
	) {
		self.isConsentGiven = isConsentGiven
		self.federalStateName = federalStateName
		self.region = region
		self.age = age
	}

	// MARK: - Public

	// MARK: - Internal

	var isConsentGiven: Bool
	var federalStateName: String?
	var region: String?
	var age: String?

	// MARK: - Private

}
