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
				let updatedTestCertificateRequests = testCertificateRequests
					.sorted { $0.registrationDate > $1.registrationDate }

				if updatedTestCertificateRequests.map({ $0.registrationToken }) != self.testCertificateRequests.map({ $0.registrationToken }) {
					self.testCertificateRequests = updatedTestCertificateRequests
				}
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
	@DidSetPublished var testCertificateRequestError: HealthCertificateServiceError.TestCertificateRequestError?

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

	func retryTestCertificateRequest(at indexPath: IndexPath) {
		let testCertificateRequest = self.testCertificateRequests[indexPath.row]
		healthCertificateService.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false
		) { [weak self] result in
			if case .failure(let error) = result {
				self?.testCertificateRequestError = error
			}
		}
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		healthCertificateService.remove(testCertificateRequest: testCertificateRequest)
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private var subscriptions = Set<AnyCancellable>()

}
