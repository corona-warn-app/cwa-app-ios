////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class HealthCertificateOverviewViewModel {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		cclService: CCLServable
	) {
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.healthCertificateRequestService = healthCertificateRequestService
		self.cclService = cclService
		
		healthCertificateService.$healthCertifiedPersons
			.sink {
				self.healthCertifiedPersons = $0
					.filter { !$0.healthCertificates.isEmpty }
				self.decodingFailedHealthCertificates = $0
					.flatMap { $0.decodingFailedHealthCertificates }
				
			}
			.store(in: &subscriptions)

		healthCertificateRequestService.$testCertificateRequests
			.sink { testCertificateRequests in
				let updatedTestCertificateRequests = testCertificateRequests
					.sorted { $0.registrationDate > $1.registrationDate }

				if updatedTestCertificateRequests.map({ $0.registrationToken }) != self.testCertificateRequests.map({ $0.registrationToken }) {
					self.testCertificateRequests = updatedTestCertificateRequests
				}
			}
			.store(in: &subscriptions)
		
		healthCertificateService.$lastSelectedScenarioIdentifier
			.sink { [weak self] identifier in
				guard let dccAdmissionCheckScenarios = self?.store.dccAdmissionCheckScenarios else {
					Log.debug("couldn't find the dccAdmissionCheckScenarios in the store")
					return
				}
				guard let selectedScenario = dccAdmissionCheckScenarios.scenarioSelection.items.first(where: {
					$0.identifier == identifier
				}) else {
					Log.debug("couldn't find a match for the selectedScenario identifier")
					return
				}
				self?.changeAdmissionScenarioStatusText = dccAdmissionCheckScenarios.labelText
				self?.changeAdmissionScenarioButtonText = selectedScenario.titleText
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case changeAdmissionScenarioStatusLabel
		case changeAdmissionScenario
		case healthCertificateScanningInfoOnTop
		case testCertificateRequest
		case healthCertificate
		case healthCertificateScanningInfo
		case decodingFailedHealthCertificates
	}

	@DidSetPublished var healthCertifiedPersons: [HealthCertifiedPerson] = []
	@DidSetPublished var decodingFailedHealthCertificates: [DecodingFailedHealthCertificate] = []
	@DidSetPublished var testCertificateRequests: [TestCertificateRequest] = []
	@DidSetPublished var testCertificateRequestError: HealthCertificateServiceError.TestCertificateRequestError?
	@DidSetPublished var changeAdmissionScenarioStatusText: DCCUIText?
	@DidSetPublished var changeAdmissionScenarioButtonText: DCCUIText?

	var isEmpty: Bool {
		numberOfRows(in: Section.testCertificateRequest.rawValue) == 0 &&
		numberOfRows(in: Section.healthCertificate.rawValue) == 0 &&
		numberOfRows(in: Section.decodingFailedHealthCertificates.rawValue) == 0
	}
	
	var numberOfSections: Int {
		Section.allCases.count
	}

	var shouldShowAlertAfterRegroup: Bool {
		return store.shouldShowRegroupingAlert
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .changeAdmissionScenarioStatusLabel:
			return rowsForAdmissionCheckScenarios
		case .changeAdmissionScenario:
			return rowsForAdmissionCheckScenarios
		case .healthCertificateScanningInfoOnTop:
			return rowsForScanningInfoOnTop
		case .testCertificateRequest:
			return testCertificateRequests.count
		case .healthCertificate:
			return healthCertifiedPersons.count
		case .healthCertificateScanningInfo:
			return rowsForAdmissionCheckScenarios
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

		healthCertificateRequestService.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false
		) { [weak self] result in
			if case .failure(let error) = result {
				self?.testCertificateRequestError = error
			}
		}
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		healthCertificateRequestService.remove(testCertificateRequest: testCertificateRequest)
	}

	func attemptToRestoreDecodingFailedHealthCertificates() {
		healthCertificateService.attemptToRestoreDecodingFailedHealthCertificates()
	}
	
	// MARK: - Private

	private(set) var store: HealthCertificateStoring
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateRequestService: HealthCertificateRequestService
	private let cclService: CCLServable
	private var subscriptions = Set<AnyCancellable>()

	private var rowsForAdmissionCheckScenarios: Int {
		if !healthCertifiedPersons.isEmpty && cclService.dccAdmissionCheckScenariosEnabled {
			return 1
		}
		return 0
	}
	
	private var rowsForScanningInfoOnTop: Int {
		if cclService.dccAdmissionCheckScenariosEnabled && healthCertifiedPersons.isEmpty {
			return 1
		} else if !cclService.dccAdmissionCheckScenariosEnabled {
			return 1
		}
		return 0
	}
}
