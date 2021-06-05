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
					.sorted()
					.reversed()
			}
			.store(in: &subscriptions)

		healthCertificateService.testCertificateRequests
			.sink { testCertificateRequests in
				self.testCertificateRequests = testCertificateRequests
					.sorted { $0.registrationDate > $1.registrationDate }
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case healthCertificate
		case createHealthCertificate
		case testCertificates
		case testCertificateRequests
		case testCertificateInfo
	}

	@DidSetPublished var healthCertifiedPersons: [HealthCertifiedPerson] = []
	@DidSetPublished var testCertificates: [HealthCertificate] = []
	@DidSetPublished var testCertificateRequests: [TestCertificateRequest] = []

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
		case .testCertificateRequests:
			return testCertificateRequests.count
		case .testCertificateInfo:
			return testCertificates.isEmpty && testCertificateRequests.isEmpty ? 1 : 0
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private var subscriptions = Set<AnyCancellable>()

}
