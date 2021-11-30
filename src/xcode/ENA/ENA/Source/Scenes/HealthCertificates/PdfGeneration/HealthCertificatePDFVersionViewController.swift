//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import LinkPresentation

class HealthCertificatePDFVersionViewController: DynamicTableViewController, UIActivityItemSource {

	// MARK: - Init

	init(
		viewModel: HealthCertificatePDFVersionViewModel,
		onTapPrintPdf: @escaping (Data) -> Void,
		onTapExportPdf: @escaping (PDFExportItem) -> Void
	) {
		self.viewModel = viewModel
		self.onTapPrintPdf = onTapPrintPdf
		self.onTapExportPdf = onTapExportPdf

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Avoid assertion when init with non-zero scale.
		let pdfView = PDFView(frame: .init(x: 0, y: 0, width: 1, height: 1))

		pdfView.document = viewModel.pdfDocument
		pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
		pdfView.autoScales = true

		view = pdfView
		view.backgroundColor = .enaColor(for: .background)
		
		let printButton = UIBarButtonItem(image: UIImage(named: "Icons_Printer"), style: .plain, target: self, action: #selector(didTapPrintButton))
		printButton.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.printButton
		let shareButton = UIBarButtonItem(image: UIImage(named: "Icons_Share"), style: .plain, target: self, action: #selector(didTapShareButton))
		shareButton.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.PrintPdf.shareButton

		if UIPrintInteractionController.isPrintingAvailable {
			navigationItem.rightBarButtonItems = [shareButton, printButton]
		} else {
			navigationItem.rightBarButtonItem = shareButton
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Need to call here again to set the nav bar size correctly.
		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.restoreOriginalNavigationBar()
		}
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
	
	@objc
	private func didTapPrintButton() {
		guard let pdfView = view as? PDFView,
			let data = pdfView.document?.dataRepresentation() else {
			Log.error("Could not create data representation of pdf to print", log: .vaccination)
			return
		}
		onTapPrintPdf(data)
	}
	
	@objc
	private func didTapShareButton() {
		guard let pdfView = view as? PDFView,
			  let data = pdfView.document?.dataRepresentation() else {
			Log.error("Could not create data representation of pdf to print", log: .vaccination)
			return
		}
		let temporaryFolder = FileManager.default.temporaryDirectory
		let pdfFileName = "healthCertificate_\(viewModel.certificatePersonName).pdf"
		let pdfFileURL = temporaryFolder.appendingPathComponent(pdfFileName)
		
		do {
			try data.write(to: pdfFileURL)
			let exportItem = PDFExportItem(subject: viewModel.shareTitle, fileURL: pdfFileURL)
			onTapExportPdf(exportItem)
		} catch {
			Log.error("Could not write the template data to the pdf file.", log: .vaccination, error: error)
		}
	}
}
