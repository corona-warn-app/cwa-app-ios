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
			self?.updatePDFDataProgressAlertMessage(pageInProgress: pageInProgress, numberOfPages: numberOfPages)
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
			if viewModel.noCertificatesExportable {
				self.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
				self.showErrorAlert(.noExportabeCertificate)
				return
			}
			
			showPDFDataProgressAlert()
			viewModel.generatePDFData { result in
				DispatchQueue.main.async { [weak self] in
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)

					switch result {
					case let .success(pdfDocument):
						self?.hidePDFDataProgressAlert(completion: { [weak self] in
							guard let self = self else { return }
							
							if self.viewModel.shouldShowPDFDataResultAlert {
								self.createPDFDataResultAlertController(pdfDocument: pdfDocument) {
									self.showPDFDataResultAlert()
								}
							} else {
								self.onTapContinue(pdfDocument)
							}
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
	
	/// Alert informs the user about the pdf creation progress
	lazy var pdfDataProgressAlertController: UIAlertController = {
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
	
	/// Alert informs the user that not all available certificates could be exported.
	private var pdfDataResultAlertController: UIAlertController?
	
	private func showPDFDataProgressAlert() {
		pdfDataProgressAlertController.message = AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressMessageInitial
		present(pdfDataProgressAlertController, animated: true)
	}
	
	private func hidePDFDataProgressAlert(completion: @escaping CompletionVoid) {
		pdfDataProgressAlertController.dismiss(animated: true) {
			completion()
		}
	}
	
	/// Updates the progress alert message, with the current pdf page that is creating at the time.
	private func updatePDFDataProgressAlertMessage(pageInProgress: Int, numberOfPages: Int) {
		let message = String(
			format: AppStrings.HealthCertificate.ExportCertificatesInfo.generatePDFProgressMessage,
			String(pageInProgress),
			String(numberOfPages)
		)

		DispatchQueue.main.async { [weak self] in
			self?.pdfDataProgressAlertController.message = message
		}
	}
	
	private func createPDFDataResultAlertController(pdfDocument: PDFDocument, completion: CompletionVoid) {
		let alert = UIAlertController(
			title: viewModel.exportableCertificatesStatus.title,
			message: viewModel.exportableCertificatesStatus.message,
			preferredStyle: .alert
		)
		
		alert.addAction(.init(
			title: viewModel.exportableCertificatesStatus.actionTitle,
			style: .default,
			handler: { [weak self] _ in
				guard let self = self else { return }
				
				switch self.viewModel.exportableCertificatesStatus {
				case .noCertificatesExportable:
					self.dismiss(animated: true)
				default:
					self.onTapContinue(pdfDocument)
				}
			}
		))
		
		pdfDataResultAlertController = alert
		
		completion()
	}
	
	private func showPDFDataResultAlert() {
		guard let pdfDataResultAlertController = pdfDataResultAlertController else { return }
		present(pdfDataResultAlertController, animated: true)
	}
	
	private func hidePDFDataResultAlert(completion: @escaping CompletionVoid) {
		pdfDataResultAlertController?.dismiss(animated: true) {
			completion()
		}
	}
}
