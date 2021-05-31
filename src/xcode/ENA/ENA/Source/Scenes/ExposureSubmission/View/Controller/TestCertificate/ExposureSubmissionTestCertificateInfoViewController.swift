////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestCertificateInfoViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

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

	// MARK: FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		Log.debug("NYD - at the moment")
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestCertificateViewModel
	private let showCancelAlert: () -> Void
	private var subscriptions = Set<AnyCancellable>()

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

		viewModel.$isPrimaryButtonEnabled
			.sink { [weak self] isEnabled in
				self?.footerView?.setEnabled(isEnabled, button: .primary)
			}
			.store(in: &subscriptions)
	}

}
