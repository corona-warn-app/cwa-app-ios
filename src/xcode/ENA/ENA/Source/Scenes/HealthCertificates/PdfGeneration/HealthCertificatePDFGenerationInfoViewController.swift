//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class HealthCertificatePDFGenerationInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		onTapContinue: @escaping (PDFView) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onTapContinue = onTapContinue
		self.onDismiss = onDismiss
		self.viewModel = HealthCertificatePDFGenerationInfoViewModel()

		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		parent?.navigationItem.hidesBackButton = true
		parent?.navigationItem.largeTitleDisplayMode = .never
		
		setupView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.setupTransparentNavigationBar()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.restoreOriginalNavigationBar()
		}
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			self.footerView?.setLoadingIndicator(true, disable: true, button: .primary)
			
			viewModel.generatePDFData(completion: { [weak self] pdfView in
				self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
				self?.onTapContinue(pdfView)
			})
		}
	}
	
	// MARK: - Private
	
	private let viewModel: HealthCertificatePDFGenerationInfoViewModel
	private let onTapContinue: (PDFView) -> Void
	private let onDismiss: () -> Void
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
