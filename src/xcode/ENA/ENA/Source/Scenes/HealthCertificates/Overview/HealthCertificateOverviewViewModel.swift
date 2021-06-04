////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateOverviewViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService
	) {
		self.healthCertificateService = healthCertificateService

		healthCertificateService.healthCertifiedPersons
			.sink { healthCertifiedPersons in
				self.healthCertifiedPersons = healthCertifiedPersons
					.filter { !$0.vaccinationCertificates.isEmpty }
				self.testCertificates = healthCertifiedPersons
					.flatMap { $0.testCertificates }
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case healthCertificate
		case createHealthCertificate
		case testCertificates
		case testCertificateInfo
	}

	@OpenCombine.Published var healthCertifiedPersons: [HealthCertifiedPerson] = []
	@OpenCombine.Published var testCertificates: [HealthCertificate] = []

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
		case .testCertificates:
			return testCertificates.count
		case .testCertificateInfo:
			return testCertificates.isEmpty ? 1 : 0
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

	func testCertificate(at indexPath: IndexPath) -> HealthCertificate? {
		guard Section(rawValue: indexPath.section) == .testCertificates,
			  testCertificates.indices.contains(indexPath.row) else {
			Log.debug("Tried to access unknown testCertificate - stop")
			return nil
		}

		return testCertificates[indexPath.row]
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private var subscriptions = Set<AnyCancellable>()

}
