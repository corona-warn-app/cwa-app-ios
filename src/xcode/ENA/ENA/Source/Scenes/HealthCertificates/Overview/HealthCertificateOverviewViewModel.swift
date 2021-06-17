////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class HealthCertificateOverviewViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		cameraAuthorizationStatus: @escaping () -> AVAuthorizationStatus = {
			AVCaptureDevice.authorizationStatus(for: .video)
		}
	) {
		self.healthCertificateService = healthCertificateService
		self.cameraAuthorizationStatus = cameraAuthorizationStatus
		
		healthCertificateService.healthCertifiedPersons
			.sink { self.healthCertifiedPersons = $0 }
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
		case createCertificate
		case missingPermission
		case testCertificateRequest
		case healthCertificate
	}

	@DidSetPublished var healthCertifiedPersons: [HealthCertifiedPerson] = []
	@DidSetPublished var testCertificateRequests: [TestCertificateRequest] = []
	@DidSetPublished var testCertificateRequestError: HealthCertificateServiceError.TestCertificateRequestError?

	var isEmpty: Bool {
		numberOfRows(in: Section.testCertificateRequest.rawValue) == 0 &&
		numberOfRows(in: Section.healthCertificate.rawValue) == 0
	}

	var isEmptyStateVisible: Bool {
		isEmpty && !showMissingPermissionSection
	}
	
	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .createCertificate:
			return showMissingPermissionSection ? 0 : 1
		case .missingPermission:
			return showMissingPermissionSection ? 1 : 0
		case .testCertificateRequest:
			return testCertificateRequests.count
		case .healthCertificate:
			return healthCertifiedPersons.count
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

	func resetBadgeCount() {
		healthCertificateService.resetUnseenTestCertificateCount()
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private let cameraAuthorizationStatus: () -> AVAuthorizationStatus
	private var subscriptions = Set<AnyCancellable>()
	
	private var showMissingPermissionSection: Bool {
		let status = cameraAuthorizationStatus()

		return status != .notDetermined && status != .authorized
	}

}
