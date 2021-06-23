////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct PreferredPersonCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificateService: HealthCertificateService
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificateService = healthCertificateService
	}

	// MARK: - Internal

	var name: String? {
		healthCertifiedPerson.name?.fullName
	}

	var dateOfBirth: String? {
		healthCertifiedPerson.dateOfBirth.flatMap {
			DCCDateStringFormatter.formatedString(from: $0)
		}
	}

	var isPreferredPerson: Bool {
		healthCertifiedPerson.isPreferredPerson
	}

	func setAsPreferredPerson(_ newValue: Bool) {
		healthCertifiedPerson.isPreferredPerson = newValue
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson
	let healthCertificateService: HealthCertificateService

}
