//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class TraceLocationPrintVersionViewController: UIViewController {

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

		self.view = viewModel.pdfView

		let printButton = UIBarButtonItem(image: UIImage(named: "Icons_Print"), style: .plain, target: self, action: #selector(didTapPrintButton))
		let shareButton = UIBarButtonItem(image: UIImage(named: "Icons_Share"), style: .plain, target: self, action: #selector(didTapShareButton))
		
		if UIPrintInteractionController.isPrintingAvailable {
			navigationItem.rightBarButtonItems = [shareButton, printButton]
		} else {
			navigationItem.rightBarButtonItem = shareButton
		}
	}

	// MARK: - Private

	private let viewModel: TraceLocationPrintVersionViewModel

	@objc
	private func didTapShareButton() {
		guard let data = viewModel.pdfView.document?.dataRepresentation() else { return }
		let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
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
