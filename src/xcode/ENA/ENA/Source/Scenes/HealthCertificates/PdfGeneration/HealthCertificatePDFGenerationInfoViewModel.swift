//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

struct HealthCertificatePDFGenerationInfoViewModel {
	
	// MARK: - Init
	
	// MARK: - Internal
	let title: String = AppStrings.HealthCertificate.PrintPDF.Info.title
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
								
			// Illustration with information text
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.PrintPDF.Info.title,
						image: UIImage(imageLiteralResourceName: "Illu_Print")
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			completion(PDFView())
		}
		
	}
	
	// MARK: - Private
	
}
