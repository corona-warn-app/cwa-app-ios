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

		setupNavigationBar()
		setupView()
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
	
	private func setupNavigationBar() {
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		
		if #available(iOS 13.0, *) {
			parent?.isModalInPresentation = true
		}
		// we need to "reset" the normal nav bar behaviour because we modified it in the screen before (HealthCertificateViewController)
		navigationItem.largeTitleDisplayMode = .automatic
		navigationItem.title = viewModel.title
		
		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
	}

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
