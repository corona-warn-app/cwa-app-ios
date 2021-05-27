////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionTestCertificateInfoViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		_ viewModel: ExposureSubmissionTestCertificateViewModel,
		showCancelAlert: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.showCancelAlert = showCancelAlert
		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		showCancelAlert()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestCertificateViewModel
	private let showCancelAlert: () -> Void

}
