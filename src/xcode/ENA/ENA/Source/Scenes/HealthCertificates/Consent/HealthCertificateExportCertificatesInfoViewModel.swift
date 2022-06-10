//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExportCertificatesInfoViewModel {
	
	// MARK: - Internal
	
	var hidesCloseButton: Bool = false
	
	let onDismiss: CompletionBool
	let onNext: CompletionVoid
	
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
	
	// MARK: Initialize
	
	init(
		onDismiss: @escaping CompletionBool,
		onNext: @escaping CompletionVoid
	) {
		self.onDismiss = onDismiss
		self.onNext = onNext
	}
}
