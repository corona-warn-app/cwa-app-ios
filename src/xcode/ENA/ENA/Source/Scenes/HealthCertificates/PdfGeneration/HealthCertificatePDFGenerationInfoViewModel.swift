//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import OpenCombine

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
								
			// Illustration with information text
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
		completion: @escaping (PDFView) -> Void
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
						Log.error("Could not fetch Vaccination value sets protobuf.", log: .vaccination, error: error)
					}
				}, receiveValue: { [weak self] valueSets in
					guard let self = self else {
						fatalError("Could not create strong self")
					}
					do {
						let pdfView = try self.healthCertificate.createPdfView(with: valueSets)
						completion(pdfView)
					} catch {
						fatalError("Could not create pdf view of healthCertificate: \(private: self.healthCertificate) with error: \(error)")
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
