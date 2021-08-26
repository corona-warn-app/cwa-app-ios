//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit
import LinkPresentation

class TraceLocationPrintVersionViewController: UIViewController, UIActivityItemSource {

	// MARK: - Init

	init(viewModel: TraceLocationPrintVersionViewModel) {
		self.viewModel = viewModel

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
		navigationController?.navigationBar.prefersLargeTitles = false

		let printButton = UIBarButtonItem(image: UIImage(named: "Icons_Printer"), style: .plain, target: self, action: #selector(didTapPrintButton))
		let shareButton = UIBarButtonItem(image: UIImage(named: "Icons_Share"), style: .plain, target: self, action: #selector(didTapShareButton))
		
		if UIPrintInteractionController.isPrintingAvailable {
			navigationItem.rightBarButtonItems = [shareButton, printButton]
		} else {
			navigationItem.rightBarButtonItem = shareButton
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

	private let viewModel: TraceLocationPrintVersionViewModel

	@objc
	private func didTapShareButton() {
		guard let data = viewModel.pdfView.document?.dataRepresentation() else { return }
		let temporaryFolder = FileManager.default.temporaryDirectory
		let pdfFileName = "cwa-qr-code.pdf"
		let pdfFileURL = temporaryFolder.appendingPathComponent(pdfFileName)
		
		do {
			try data.write(to: pdfFileURL)
		} catch {
			Log.error("Could not write the template data to the pdf file.", log: .qrCode, error: error)
		}
		
		let exportItem = PDFExportItem(subject: viewModel.shareTitle, fileURL: pdfFileURL)
		let activityViewController = UIActivityViewController(activityItems: [exportItem], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

	@objc
	private func didTapPrintButton() {
		guard let data = viewModel.pdfView.document?.dataRepresentation() else { return }
		
		let printController = UIPrintInteractionController.shared
		printController.printingItem = data
		printController.present(animated: true, completionHandler: nil)
	}
}

class PDFExportItem: NSObject, UIActivityItemSource {

	// MARK: - Init
	
	init(subject: String, fileURL: URL) {
		self.subject = subject
		self.fileURL = fileURL
	}
	
	// MARK: - Protocol UIActivityItemSource
	
	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		return ""
	}
	
	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		return fileURL
	}
	
	func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
		switch activityType {
		case .mail?:
			return subject
		default:
			return ""
		}
	}
	
	// MARK: - Private
	
	private let subject: String
	private let fileURL: URL
}
