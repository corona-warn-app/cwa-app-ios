//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import OpenCombine

class HealthCertificateExportCertificatesInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		viewModel: HealthCertificateExportCertificatesInfoViewModel,
		onDismiss: @escaping CompletionBool,
		onTapContinue: @escaping (PDFDocument) -> Void,
		showErrorAlert: @escaping (HealthCertificatePDFGenerationError) -> Void
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss
		self.onTapContinue = onTapContinue
		self.showErrorAlert = showErrorAlert
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(true)
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			footerView?.setLoadingIndicator(true, disable: true, button: .primary)
			viewModel.generatePDFData { result in
				DispatchQueue.main.async { [weak self] in
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)

					switch result {
					case let .success(pdfDocument):
						self?.onTapContinue(pdfDocument)
					case let .failure(error):
						self?.showErrorAlert(error)
					}
				}
			}
		}
	}

	// MARK: - Private
	
	private let viewModel: HealthCertificateExportCertificatesInfoViewModel
	private let onDismiss: CompletionBool
	private let onTapContinue: (PDFDocument) -> Void
	private let showErrorAlert: (HealthCertificatePDFGenerationError) -> Void
}

class HealthCertificateExportCertificatesInfoViewModel {
	
	// MARK: - Init
	
	init(
		healthCertificateService: HealthCertificateService,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.healthCertificateService = healthCertificateService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}
	
	// MARK: - Internal
	
	let title: String = "Zertifikate exportieren" // TODO: localize
	
	var dynamicTableViewModel: DynamicTableViewModel {
		.init([
			.section(
				header:
					.image(
						UIImage(imageLiteralResourceName: "TBD"),
						title: nil,
						accessibilityLabel: "TBD",
						accessibilityIdentifier: "TDB",
						height: 283.0,
						accessibilityTraits: .image
					),
				cells: [
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_04"),
						text: .string("Sie können in einem Schritt alle in Ihrer App vorhandenen Zertifikate in einem gemeinsamen PDF-Dokument speichern. Auf das PDF-Dokument haben zunächst nur Sie Zugriff. Sie können im Anschluss entscheiden, ob Sie es auf Ihrem Smartphone speichern oder in andere Apps importieren möchten."), // TODO: localize,
						alignment: .top
					)
				])
		])
	}
	
	func generatePDFData(
		completion: @escaping (Result<PDFDocument, HealthCertificatePDFGenerationError>) -> Void
	) {
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							Log.error("Signature verification error.", log: .vaccination, error: error)
						}
						Log.error("Could not fetch value sets and so failed to create pdf view of all filtered health certificates with error: \(error)")
						completion(.failure(.fetchValueSets))
					}
				}, receiveValue: { [weak self] valueSets in
					guard let self = self else {
						completion(.failure(.createStrongPointer))
						return
					}
					do {
						let mergedPDFDocument = PDFDocument()
						let selectedHealthCertificates = self.filteredHealthCertificates(healthCertifiedPersons: self.healthCertificateService.healthCertifiedPersons.sorted())
						for (index, healthCertificate) in selectedHealthCertificates.enumerated() {
							let pdfDocument = try healthCertificate.pdfDocument(with: valueSets)
							
							guard let pdfPage = pdfDocument.page(at: 0) else {
								return
							}
							
							mergedPDFDocument.insert(pdfPage, at: index)
						}
						completion(.success(mergedPDFDocument))
					} catch {
						Log.error("Could not create pdf view of all filtered health certificates with error: \(error)")
						completion(.failure(.pdfGenerationFailed))
					}
				}
			)
			.store(in: &subscriptions)
	}
	
	func filteredHealthCertificates(healthCertifiedPersons: [HealthCertifiedPerson]) -> [HealthCertificate] {
		var allFilteredHealthCertificates: [HealthCertificate] = []
		for healthCertifiedPerson in healthCertifiedPersons {
			/*
			 * Filter by validity state:
			 * - DCCs shall be filtered for those DCCs where the validty state is one of VALID, EXPIRING_SOON, EXPIRED, or INVALID.
			 * Filter by type-specific criteria:
			 * - for Test Certificates, the time difference between the time represented by t[0].sc and the current device time is <= 72 hours
			 * - for other certificate types, no additional filter criteria applies (i.e. all certificates pass the filter)
			 */
			var filteredHealthCertificates = healthCertifiedPerson.healthCertificates.filter {
				$0.isValidityStateConsiderableForExporting && $0.isTypeSpecificCriteriaValid
			}
			
			// sorting on the basis of certificate type
			filteredHealthCertificates = filteredHealthCertificates.sorted(by: >)
			
			allFilteredHealthCertificates.append(contentsOf: filteredHealthCertificates)
		}
		return allFilteredHealthCertificates
	}
	
	// MARK: - Private
	
	private let healthCertificateService: HealthCertificateService
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private var subscriptions = Set<AnyCancellable>()

}
