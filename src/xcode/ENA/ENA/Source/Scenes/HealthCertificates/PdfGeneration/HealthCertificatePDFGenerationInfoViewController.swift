//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class HealthCertificatePDFGenerationInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		onTapContinue: @escaping (PDFDocument) -> Void,
		onDismiss: @escaping () -> Void,
		showErrorAlert: @escaping (HealthCertificatePDFGenerationError) -> Void
	) {
		self.onTapContinue = onTapContinue
		self.onDismiss = onDismiss
		self.showErrorAlert = showErrorAlert
		self.viewModel = HealthCertificatePDFGenerationInfoViewModel(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

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
			
			DispatchQueue.main.async { [weak self] in
				self?.viewModel.generatePDFData(completion: { result in
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
					switch result {
					case let .success(pdfDocument):
						self?.onTapContinue(pdfDocument)
					case let .failure(error):
						self?.showErrorAlert(error)
					}
				})
			}
		}
	}
	
	// MARK: - Private
	
	private let viewModel: HealthCertificatePDFGenerationInfoViewModel
	private let onTapContinue: (PDFDocument) -> Void
	private let onDismiss: () -> Void
	private let showErrorAlert: (HealthCertificatePDFGenerationError) -> Void
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
}
