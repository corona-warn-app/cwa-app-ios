//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExportCertificatesInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		viewModel: HealthCertificateExportCertificatesInfoViewModel,
		onDismiss: @escaping CompletionBool
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss
		
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
		// TODO: handle tap footer
		print(#function)
	}
	
	// MARK: - Private
	
	private let viewModel: HealthCertificateExportCertificatesInfoViewModel
	private let onDismiss: CompletionBool
}

class HealthCertificateExportCertificatesInfoViewModel {
	
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
}
