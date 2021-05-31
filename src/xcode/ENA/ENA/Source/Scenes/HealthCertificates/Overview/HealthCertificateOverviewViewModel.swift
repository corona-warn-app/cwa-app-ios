////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateOverviewViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateServiceProviding
	) {
		self.healthCertificateService = healthCertificateService

		healthCertificateService.healthCertifiedPersons
			.sink { healthCertifiedPersons in
				self.healthCertifiedPersons = healthCertifiedPersons
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case healthCertificate
		case createHealthCertificate
		case testCertificateInfo
	}

	@OpenCombine.Published var healthCertifiedPersons: [HealthCertifiedPerson] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return 1
		case .healthCertificate:
			return healthCertifiedPersons.count
		case .createHealthCertificate:
			return healthCertifiedPersons.isEmpty ? 1 : 0
		case .testCertificateInfo:
			return 1
		case .none:
			fatalError("Invalid section")
		}
	}

	func healthCertifiedPerson(at indexPath: IndexPath) -> HealthCertifiedPerson? {
		guard Section(rawValue: indexPath.section) == .healthCertificate,
			  healthCertificateService.healthCertifiedPersons.value.indices.contains(indexPath.row) else {
			Log.debug("Tried to access unknown healthCertifiedPersons - stop")
			return nil
		}
		return healthCertificateService.healthCertifiedPersons.value[indexPath.row]
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateServiceProviding
	private var subscriptions = Set<AnyCancellable>()

}
