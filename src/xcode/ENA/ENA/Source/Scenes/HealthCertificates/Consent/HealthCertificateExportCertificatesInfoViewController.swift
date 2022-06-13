//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

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
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if !viewModel.hidesCloseButton {
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}
		
		setupView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setupStatusBarViewBackgroundColorIfNeeded()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		revertStatusBarViewBackgroundColorIfNeeded()
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
	
	private func setupView() {
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		view.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
	}
}
