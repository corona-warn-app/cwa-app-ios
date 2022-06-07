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
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if !viewModel.hidesCloseButton {
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}
		
		setupView()
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
	
	private func setupView() {
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		view.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
	}
}

class HealthCertificateExportCertificatesInfoViewModel {
	
	// MARK: - Internal
	
	let title: String = "Zertifikate exportieren" // TODO: localize
	var hidesCloseButton: Bool = false
	
	var dynamicTableViewModel: DynamicTableViewModel {
		.init([
			.section(
				cells: [
					.headlineWithImage(
						headerText: "Zertifikate exportieren", // TODO: localize
						image: UIImage(imageLiteralResourceName: "Illu_Certificate_Export")
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_04"),
						text: .string("Sie können in einem Schritt alle in Ihrer App vorhandenen Zertifikate in einem gemeinsamen PDF-Dokument speichern. Auf das PDF-Dokument haben zunächst nur Sie Zugriff. Sie können im Anschluss entscheiden, ob Sie es auf Ihrem Smartphone speichern oder in andere Apps importieren möchten."), // TODO: localize,
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock2"),
						text: .string("Beachten Sie, dass das PDF-Dokument sensible Informationen enthält. Wir empfehlen Ihnen, hiermit sorgsam umzugehen und es nur Personen vorzuzeigen, denen Sie vertrauen und die zur Prüfung des Nachweises berechtigt sind."), // TODO: localize
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Smartphone"),
						text: .string("Wir empfehlen, das PDF-Dokument nicht zu veröffentlichen und nicht per E-Mail zu versenden oder über andere Apps zu teilen."), // TODO: localize
						alignment: .top
					)
				])
		])
	}
}
