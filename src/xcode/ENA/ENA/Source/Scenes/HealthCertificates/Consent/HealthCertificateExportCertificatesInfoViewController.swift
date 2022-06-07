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
	
	let title: String = AppStrings.HealthCertificate.ExportCertificatesInfo.title
	var hidesCloseButton: Bool = false
	
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
}
