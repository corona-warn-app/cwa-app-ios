//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import PDFKit

class HealthCertificateExportCertificatesInfoViewModel {
	
	// MARK: - Init
	
	init(
		healthCertifiedPersons: [HealthCertifiedPerson],
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.healthCertifiedPersons = healthCertifiedPersons
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}
	
	// MARK: - Internal
	
	var hidesCloseButton: Bool = false
	
	var onChangeGeneratePDFDataProgess: ((_ pageInProgress: Int, _ ofTotal: Int) -> Void)?
	
	var numberOfExportableCertificates: Int {
		filteredHealthCertificates(healthCertifiedPersons: healthCertifiedPersons).count
	}
	
	var noCertificatesExportable: Bool {
		numberOfExportableCertificates == 0
	}
	
	var shouldShowPDFDataResultAlert: Bool {
		numberOfNotExportableCertificates > 0 && numberOfNotExportableCertificates < numberOfCertificates
	}
	
	var exportableCertificatesStatus: ExportableCertificatesStatus {
		if numberOfNotExportableCertificates > 1, !noCertificatesExportable {
			return .someCertificatesNotExportable(amount: numberOfExportableCertificates, ofTotalCertificates: numberOfCertificates)
			
		} else if numberOfNotExportableCertificates == 1, !noCertificatesExportable {
			return .oneCertificateNotExportable(totalCertificates: numberOfCertificates)

		} else {
			return .noCertificatesExportable
		}
	}
	
	var dynamicTableViewModel: DynamicTableViewModel {
		.init([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.ExportCertificatesInfo.title,
						image: UIImage(imageLiteralResourceName: "Illu_Certificate_Export"),
						imageAccessibilityLabel: AppStrings.HealthCertificate.ExportCertificatesInfo.headerImageDescription,
						imageAccessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.ExportCertificatesInfo.headerImage
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_04"),
						text: .string(AppStrings.HealthCertificate.ExportCertificatesInfo.hint01),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock2"),
						text: .string(AppStrings.HealthCertificate.ExportCertificatesInfo.hint02),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Smartphone"),
						text: .string(AppStrings.HealthCertificate.ExportCertificatesInfo.hint03),
						alignment: .top
					)
				])
		])
	}
	
	func generatePDFData(
		completion: @escaping (Result<PDFDocument, HealthCertificatePDFGenerationError>) -> Void
	) {
		// Delay to give user a chance to see the content on info alert or cancel the process
		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
			self.vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
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
							
							// DCCs shall be sorted ascending by the name of the holder
							let selectedHealthCertificates = self.filteredHealthCertificates(healthCertifiedPersons: self.healthCertifiedPersons.sorted())
							
							self.onChangeGeneratePDFDataProgess?(0, selectedHealthCertificates.count)
							
							for (index, healthCertificate) in selectedHealthCertificates.enumerated() {
								let pdfDocument = try healthCertificate.pdfDocument(with: valueSets)
								
								guard let pdfPage = pdfDocument.page(at: 0) else {
									return
								}
								
								self.onChangeGeneratePDFDataProgess?(index + 1, self.numberOfCertificates)
								mergedPDFDocument.insert(pdfPage, at: index)
							}
							
							completion(.success(mergedPDFDocument))
						} catch {
							Log.error("Could not create pdf view of all filtered health certificates with error: \(error)")
							completion(.failure(.batchPDFGenerationFailed))
						}
					}
				)
				.store(in: &self.subscriptions)
		})
	}
	
	func removeAllSubscriptions() {
		subscriptions.removeAll()
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
			
			// DCCs shall be sorted ascending by the date attributes depending on the type of the DCC
			filteredHealthCertificates = filteredHealthCertificates.sorted(by: >)
			
			allFilteredHealthCertificates.append(contentsOf: filteredHealthCertificates)
		}
		return allFilteredHealthCertificates
	}
	
	// MARK: - Private
	
	private let healthCertifiedPersons: [HealthCertifiedPerson]
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private var subscriptions = Set<AnyCancellable>()
	
	private var numberOfCertificates: Int {
		healthCertifiedPersons.flatMap { $0.healthCertificates }.count
	}
	
	private var numberOfNotExportableCertificates: Int {
		numberOfCertificates - numberOfExportableCertificates
	}
}

extension HealthCertificateExportCertificatesInfoViewModel {
	enum ExportableCertificatesStatus {
		case someCertificatesNotExportable(amount: Int, ofTotalCertificates: Int)
		case oneCertificateNotExportable(totalCertificates: Int)
		case noCertificatesExportable
		
		var title: String {
			switch self {
			case .someCertificatesNotExportable, .oneCertificateNotExportable:
				return AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResultTitleOneOrSomeCertificatesNotExportable
			case .noCertificatesExportable:
				return AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResulTitleNoCertificatesExportable
			}
		}
		
		var message: String {
			switch self {
			case let .someCertificatesNotExportable(amount, ofTotalCertificates):
				return String(
					format: AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResultMessageSomeCertificatesNotExportable,
					String(amount),
					String(ofTotalCertificates)
				)
			case let .oneCertificateNotExportable(totalCertificates):
				return String(
					format: AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResultMessageOneCertificateNotExportable,
					String(totalCertificates)
				)
			case .noCertificatesExportable:
				return AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResultMessageNoCertificatesExportable
			}
		}
		
		var actionTitle: String {
			AppStrings.HealthCertificate.ExportCertificatesInfo.alertPDFResultOkayButton
		}
	}
}
