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
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
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

	private func setupView() {
		parent?.navigationItem.title = AppStrings.ExposureSubmission.TestCertificate.Info.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		parent?.navigationItem.hidesBackButton = true

		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ExposureSubmissionTestCertificateViewModel.ReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}

}
