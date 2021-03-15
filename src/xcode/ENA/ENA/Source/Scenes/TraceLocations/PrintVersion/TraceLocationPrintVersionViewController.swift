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

		self.view = PDFView()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapExportButton))
	}

	// MARK: - Private

	private let viewModel: TraceLocationPrintVersionViewModel

	@objc
	private func didTapExportButton() {
		let activityViewController = UIActivityViewController(activityItems: [""], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

}
