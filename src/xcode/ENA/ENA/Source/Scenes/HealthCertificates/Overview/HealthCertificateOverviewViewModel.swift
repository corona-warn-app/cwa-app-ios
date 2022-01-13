////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class HealthCertificateOverviewViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService
	) {
		self.healthCertificateService = healthCertificateService

		healthCertificateService.$healthCertifiedPersons
			.sink {
				self.healthCertifiedPersons = $0
					.filter { !$0.healthCertificates.isEmpty }
				self.decodingFailedHealthCertificates = $0
					.flatMap { $0.decodingFailedHealthCertificates }
			}
			.store(in: &subscriptions)

		healthCertificateService.$testCertificateRequests
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
		case createCertificate
		case testCertificateRequest
		case healthCertificate
		case decodingFailedHealthCertificates
	}

	@DidSetPublished var healthCertifiedPersons: [HealthCertifiedPerson] = []
	@DidSetPublished var decodingFailedHealthCertificates: [DecodingFailedHealthCertificate] = []
	@DidSetPublished var testCertificateRequests: [TestCertificateRequest] = []
	@DidSetPublished var testCertificateRequestError: HealthCertificateServiceError.TestCertificateRequestError?

	var isEmpty: Bool {
		numberOfRows(in: Section.testCertificateRequest.rawValue) == 0 &&
		numberOfRows(in: Section.healthCertificate.rawValue) == 0 &&
		numberOfRows(in: Section.decodingFailedHealthCertificates.rawValue) == 0
	}
	
	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .createCertificate:
			return 1
		case .testCertificateRequest:
			return testCertificateRequests.count
		case .healthCertificate:
			return healthCertifiedPersons.count
		case .decodingFailedHealthCertificates:
			return decodingFailedHealthCertificates.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func retryTestCertificateRequest(at indexPath: IndexPath) {
		guard let testCertificateRequest = testCertificateRequests[safe: indexPath.row] else {
			return
		}

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

	func attemptToRestoreDecodingFailedHealthCertificates() {
		healthCertificateService.healthCertifiedPersons.forEach {
			$0.attemptToRestoreDecodingFailedHealthCertificates()
		}
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private var subscriptions = Set<AnyCancellable>()

}
