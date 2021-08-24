//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import LinkPresentation

class HealthCertificatePDFVersionViewController: DynamicTableViewController, DismissHandling, UIActivityItemSource {

	// MARK: - Init

	init(
		viewModel: HealthCertificatePDFVersionViewModel,
		onTapPrintPdf: @escaping (Data) -> Void,
		onTapExportPdf: @escaping (PDFExportItem) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onTapPrintPdf = onTapPrintPdf
		self.onTapExportPdf = onTapExportPdf
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view = viewModel.pdfView
		view.backgroundColor = .enaColor(for: .background)
		

		let printButton = UIBarButtonItem(image: UIImage(named: "Icons_Printer"), style: .plain, target: self, action: #selector(didTapPrintButton))
		let shareButton = UIBarButtonItem(image: UIImage(named: "Icons_Share"), style: .plain, target: self, action: #selector(didTapShareButton))
		
		if UIPrintInteractionController.isPrintingAvailable {
			navigationItem.rightBarButtonItems = [shareButton, printButton]
		} else {
			navigationItem.rightBarButtonItem = shareButton
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.prefersLargeTitles = false
		// Must be set here, otherwise navBar will be translucent.
		navigationController?.navigationBar.isTranslucent = false
	}
	
	// MARK: - DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Protocol UIActivityItemSource

	func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
		return viewModel.shareTitle
	}

	func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		if activityType == .mail {
			return ""
		}

		return viewModel.shareTitle
	}

	@available(iOS 13.0, *)
	func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
		let metadata = LPLinkMetadata()
		metadata.title = viewModel.shareTitle
		return metadata
	}

	func activityViewController(_: UIActivityViewController, subjectForActivityType _: UIActivity.ActivityType?) -> String {
		return viewModel.shareTitle
	}

	// MARK: - Private

	private let viewModel: HealthCertificatePDFVersionViewModel
	private let onTapPrintPdf: (Data) -> Void
	private let onTapExportPdf: (PDFExportItem) -> Void
	private let onDismiss: () -> Void
	
	@objc
	private func didTapPrintButton() {
		guard let data = viewModel.pdfView.document?.dataRepresentation() else {
			Log.error("Could not create data representation of pdf to print", log: .vaccination)
			return
		}
		onTapPrintPdf(data)
	}
	
	@objc
	private func didTapShareButton() {
		guard let data = viewModel.pdfView.document?.dataRepresentation() else {
			Log.error("Could not create data representation of pdf to print", log: .vaccination)
			return
		}
		let temporaryFolder = FileManager.default.temporaryDirectory
		let pdfFileName = "healthCertificate_\(viewModel.certificatePersonName).pdf"
		let pdfFileURL = temporaryFolder.appendingPathComponent(pdfFileName)
		
		do {
			try data.write(to: pdfFileURL)
		} catch {
			Log.error("Could not write the template data to the pdf file.", log: .vaccination, error: error)
		}
		
		let exportItem = PDFExportItem(subject: viewModel.shareTitle, fileURL: pdfFileURL)
		onTapExportPdf(exportItem)
	}
}
