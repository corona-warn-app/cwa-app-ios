////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class PreferredPersonCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificateService: HealthCertificateService
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificateService = healthCertificateService

		healthCertifiedPerson.$isPreferredPerson
			.sink { [weak self] in
				self?.isPreferredPerson = $0
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	var name: String? {
		healthCertifiedPerson.name?.fullName
	}

	var dateOfBirth: String? {
		healthCertifiedPerson.dateOfBirth
			.flatMap {
				DCCDateStringFormatter.localizedFormattedString(from: $0)
			}
			.flatMap {
				String(format: AppStrings.HealthCertificate.Person.dateOfBirth, $0)
			}
	}

	var description: String? {
		guard let name = name else {
			return nil
		}

		return String(format: AppStrings.HealthCertificate.Person.preferredPersonDescription, name)
	}

	@DidSetPublished var isPreferredPerson: Bool = false

	func setAsPreferredPerson(_ newValue: Bool) {
		healthCertifiedPerson.isPreferredPerson = newValue
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson
	let healthCertificateService: HealthCertificateService

	private var subscriptions = Set<AnyCancellable>()

}
