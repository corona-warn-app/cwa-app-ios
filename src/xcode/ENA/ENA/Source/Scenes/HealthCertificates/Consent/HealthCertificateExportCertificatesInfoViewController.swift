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
		
		viewModel.onChangeGeneratePDFDataProgess = { [weak self] pageInProgress, numberOfPages in
			self?.updatePDFDataAlertMessage(pageInProgress: pageInProgress, numberOfPages: numberOfPages)
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
			
			// if the filtered `set of DCCs` is empty, an info message shall be displayed to the user to inform them that there are no certificates to be exported.
			if viewModel.numberOfExportableCertificates == 0 {
				self.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
				self.showErrorAlert(.noExportabeCertificate)
				return
			}
			
			showPDFDataAlert()
			viewModel.generatePDFData { result in
				DispatchQueue.main.async { [weak self] in
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)

					switch result {
					case let .success(pdfDocument):
						self?.hidePDFDataAlert(completion: { [weak self] in
							self?.onTapContinue(pdfDocument)
						})
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
	
	lazy var pdfDataAlertController: UIAlertController = {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressTitle,
			message: AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressMessageInitial,
			preferredStyle: .alert
		)
		
		alert.addAction(.init(
			title: AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressCancelButton,
			style: .cancel,
			handler: { [weak self] _ in
				self?.viewModel.removeAllSubscriptions()
				self?.onDismiss(true)
			}
		))

		return alert
	}()
	
	private func showPDFDataAlert() {
		pdfDataAlertController.message = AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressMessageInitial
		present(pdfDataAlertController, animated: true)
	}
	
	private func hidePDFDataAlert(completion: @escaping CompletionVoid) {
		pdfDataAlertController.dismiss(animated: true) {
			completion()
		}
	}
	
	private func updatePDFDataAlertMessage(pageInProgress: Int, numberOfPages: Int) {
		let message = String(
			format: AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressMessage,
			String(pageInProgress),
			String(numberOfPages)
		)

		DispatchQueue.main.async { [weak self] in
			self?.pdfDataAlertController.message = message
		}
	}
}
