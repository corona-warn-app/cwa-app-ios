//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import OpenCombine

enum HealthCertificatePDFGenerationError: LocalizedError {
	case fetchValueSets
	case createStrongPointer
	case pdfGenerationFailed
	
	var errorDescription: String? {
		switch self {
		case .fetchValueSets, .createStrongPointer, .pdfGenerationFailed:
			return "\(AppStrings.HealthCertificate.PrintPDF.ErrorAlert.fetchValueSets.message)"
		}
	}
}

final class HealthCertificatePDFGenerationInfoViewModel {
	
	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}
	
	// MARK: - Internal
	
	let title: String = AppStrings.HealthCertificate.PrintPDF.Info.title
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.PrintPDF.Info.title,
						image: UIImage(imageLiteralResourceName: "Illu_Certificate_Export")
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_04"),
						text: .string(AppStrings.HealthCertificate.PrintPDF.Info.section01),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock2"),
						text: .string(AppStrings.HealthCertificate.PrintPDF.Info.section02),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Smartphone"),
						text: .string(AppStrings.HealthCertificate.PrintPDF.Info.section03),
						alignment: .top
					)
				]
			)
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
						Log.error("Could not fetch value sets and so failed to create pdf view of healthCertificate: \(private: self.healthCertificate) with error: \(error)")
						completion(.failure(.fetchValueSets))
					}
				}, receiveValue: { [weak self] valueSets in
					guard let self = self else {
						completion(.failure(.createStrongPointer))
						return
					}
					do {
						let pdfDocument = try self.healthCertificate.pdfDocument(with: valueSets)
						completion(.success(pdfDocument))
					} catch {
						Log.error("Could not create pdf view of healthCertificate: \(private: self.healthCertificate) with error: \(error)")
						completion(.failure(.pdfGenerationFailed))
					}
				}
			)
			.store(in: &subscriptions)
	}
	
	// MARK: - Private
	
	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private var subscriptions = Set<AnyCancellable>()
}
